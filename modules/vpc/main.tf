########################################
# 가용 AZ 정보 조회
########################################
data "aws_availability_zones" "available" {
  state = "available" # 사용 가능한 AZ 목록
}

########################################
# VPC 생성
########################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

########################################
# 인터넷 게이트웨이 (Public Subnet 인터넷 연결용)
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

########################################
# 퍼블릭 서브넷 생성
########################################
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true # EC2 생성 시 Public IP 자동 할당
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name                                            = "${var.project_name}-public-${count.index}"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}

########################################
# 프라이빗 서브넷 생성
########################################
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name                                            = "${var.project_name}-private-${count.index}"
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}

########################################
# NAT Gateway (Private Subnet → 인터넷 outbound)
########################################

# NAT용 Elastip IP 생성
resource "aws_eip" "nat" {
  domain = "vpc"
}
# NAT Gateway 생성
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id          # 생성한 NAT용 Elastic IP에 연결
  subnet_id     = aws_subnet.public[0].id # 첫 번째 public subnet에 배치
}

########################################
# 퍼블릭 라우트 테이블
########################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

# 퍼블릭 서브넷 → IGW 인터넷 라우팅
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# 퍼블릭 서브넷과 퍼블릭 라우트 테이블 연결
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

########################################
# 프라이빗 라우트 테이블
########################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

# 프라이빗 서브넷 → NAT Gateway 라우팅 (인터넷 outbound만 허용)
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

# 프라이빗 서브넷과 프라이빗 라우트 테이블 연결
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
