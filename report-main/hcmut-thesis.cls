\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hcmut-thesis}[2024/05/20 HCMUT Thesis Class Redesigned]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{memoir}}
\ProcessOptions\relax
\LoadClass[12pt,a4paper]{memoir}

% ===================================================
%    PACKAGES
% ===================================================
\RequirePackage[utf8]{vntex,inputenc}
\RequirePackage{anyfontsize,mathptmx} % Font Times New Roman
\RequirePackage[T5]{fontenc}
\RequirePackage{geometry,graphicx,indentfirst,setspace}
\RequirePackage{tikz}
\RequirePackage{array} % Căn chỉnh bảng tốt hơn
\RequirePackage[center]{caption}
\RequirePackage{hyperref}
\RequirePackage[super,square,sort]{natbib}
\RequirePackage{amsmath}
\RequirePackage[nameinlink]{cleveref}
\RequirePackage[english]{babel}

\usetikzlibrary{calc}

% ===================================================
%    VARIABLES & DATA DEFINITIONS
% ===================================================

% 1. School & Dept
\newcommand{\@upperuniname}{ĐẠI HỌC QUỐC GIA THÀNH PHỐ HỒ CHÍ MINH}
\newcommand{\@uniname}{TRƯỜNG ĐẠI HỌC BÁCH KHOA}
\newcommand{\@deptname}{KHOA KHOA HỌC VÀ KỸ THUẬT MÁY TÍNH}
\newcommand{\deptname}[1]{\renewcommand{\@deptname}{#1}}

% 2. Report Info
\newcommand{\@reporttype}{Luận văn tốt nghiệp}
\newcommand{\reporttype}[1]{\renewcommand{\@reporttype}{#1}}

\newcommand{\@subtitle}{} % Thêm subtitle
\newcommand{\subtitle}[1]{\renewcommand{\@subtitle}{#1}}

\newcommand{\@major}{KHOA HỌC MÁY TÍNH} % Default Major
\newcommand{\major}[1]{\renewcommand{\@major}{#1}} 

\renewcommand{\@title}{REPORT TITLE}

% 3. Personnel
\newcommand{\@defcouncil}{Tên hội đồng}
\newcommand{\defcouncil}[1]{\renewcommand{\@defcouncil}{#1}}

\newcommand{\@supervisor}{Tên giảng viên hướng dẫn}
\newcommand{\supervisor}[1]{\renewcommand{\@supervisor}{#1}}

\newcommand{\@secretary}{} % Thêm secretary
\newcommand{\secretary}[1]{\renewcommand{\@secretary}{#1}}

\newcommand{\@stuname}{}
\newcommand{\stuname}[1]{\renewcommand{\@stuname}{#1}}

% 4. Date & Place
\newcommand{\Month}{
  \ifcase \the\month
  \or Tháng 1 \or Tháng 2 \or Tháng 3 \or Tháng 4 \or Tháng 5 \or Tháng 6
  \or Tháng 7 \or Tháng 8 \or Tháng 9 \or Tháng 10 \or Tháng 11 \or Tháng 12
  \fi
}
\newcommand{\@reportplace}{TP. HỒ CHÍ MINH}
\newcommand{\@reporttime}{\Month, \the\year}

% ===================================================
%    LAYOUT CONFIGURATION
% ===================================================
\geometry{
  paper=a4paper,
  left=3cm, right=2cm, top=2.5cm, bottom=2.5cm,
  includeheadfoot=true
}

\OnehalfSpacing
\raggedbottom
\setsecnumdepth{subsection}
\settocdepth{subsection}

% Header & Footer
\makepagestyle{thesis}
\makeheadrule{thesis}{\textwidth}{0.3pt}
\makeoddhead{thesis}{}{}{\bfseries\rightmark}
\makeevenhead{thesis}{}{}{\bfseries\leftmark}
\makeoddfoot{thesis}{}{\thepage}{}
\makeevenfoot{thesis}{}{\thepage}{}
\aliaspagestyle{chapter}{thesis}
\setlength{\headheight}{18pt}
\pagestyle{thesis}

% ===================================================
%    COVER PAGE DESIGN (REMASTERED)
% ===================================================
\def\coverpage{
  \pagestyle{empty}
  
  % 1. Border (Khung viền)
  \begin{tikzpicture}[remember picture,overlay]
    \draw[line width=3pt] 
      ($(current page.north west) + (3.0cm,-2.0cm)$) 
      rectangle 
      ($(current page.south east) + (-2.0cm,2.0cm)$);
    \draw[line width=1pt] 
      ($(current page.north west) + (2.9cm,-1.9cm)$) 
      rectangle 
      ($(current page.south east) + (-1.9cm,1.9cm)$);
  \end{tikzpicture}

  \begin{center}
    \vspace*{-1cm}
    
    % 2. University Info
    \textbf{\large \@upperuniname}\\[0.3cm]
    \textbf{\large \@uniname}\\[0.3cm]
    \textbf{\large \@deptname}
    
    \vspace{1.0cm}
    
    % 3. Logo
    \includegraphics[scale=0.30]{graphics/hcmut.png} % Đảm bảo bạn có file ảnh này
    
    \vspace{1.0cm}
    
    % 4. Report Type & Title
    % Dùng parbox để xử lý xuống dòng tự động
    \parbox{\linewidth}{\centering \bfseries \Large \@reporttype}\\[0.5cm]
    \ifx\@subtitle\empty \else 
        \parbox{\linewidth}{\centering \bfseries \normalsize \@subtitle}\\[0.5cm]
    \fi
    
    \vspace{0.5cm}
    
    % Tên đề tài (Màu xanh nếu set trong main, ở đây chỉ định dạng Size)
    \parbox{0.9\linewidth}{\centering \bfseries \fontsize{18}{22}\selectfont \@title}
    
    \vspace{0.7cm}
    \textbf{CHUYÊN NGÀNH: \@major}
    \vspace{0.7cm}
    
    % 5. Information Block (Căn chỉnh bằng Tabular)
    % Cấu trúc: Label (đậm, bên trái) | Nội dung (bên phải)
    \begin{tabular}{@{} p{3.5cm} l @{}}
        \textbf{HỘI ĐỒNG:}      & \@defcouncil \\[0.3cm]
        \textbf{GVHD:}& \@supervisor \\[0.3cm]
        \ifx\@secretary\empty \else
        \textbf{THƯ KÝ:}    & \@secretary \\[0.3cm]
        \fi
    \end{tabular}

    \vspace{0.3cm}
    ---o0o---
    \vspace{0.3cm}
    
    % Phần sinh viên: Để linh hoạt cho 1 hoặc nhiều SV, 
    % hiển thị nguyên khối người dùng nhập vào
    {\centering
    \bfseries \@stuname
    \par}

    \vspace*{\fill}
    
    % 6. Date
    \fontsize{12}{14}\selectfont
    \@reportplace, \@reporttime
    
  \end{center}
  \cleardoublepage
  \pagestyle{thesis}
}

% ===================================================
%    UTILITIES
% ===================================================
\AtBeginDocument{\renewcommand*\bibname{Tài liệu tham khảo}}

\hypersetup{
  colorlinks=true,
  linkcolor=black,
  citecolor=red,
  urlcolor=blue
}