import '../domain/learning_course.dart';

const mockLearningCourses = <LearningCourse>[
  LearningCourse(
    id: 'bartending-basics',
    title: 'Bartending cơ bản',
    description: 'Nắm vững dụng cụ, cách cân bằng hương vị và kỹ thuật pha mocktail tại nhà.',
    level: CourseLevel.beginner,
    artwork: CourseArtworkType.bartending,
    chapters: [
      CourseChapter(
        title: 'Bắt đầu từ căn bếp',
        lessons: [
          CourseLesson(
            id: 'bartending-tools',
            title: 'Dụng cụ và vệ sinh quầy pha chế',
            summary: 'Chuẩn bị một góc pha chế gọn gàng, an toàn mà không cần nhiều dụng cụ chuyên nghiệp.',
            estimatedMinutes: 8,
            sections: [
              LessonSection(
                title: 'Bộ dụng cụ tối thiểu',
                body: 'Một chiếc ly đong, thìa cán dài, dao nhỏ, thớt và dụng cụ ép chanh là đủ để bắt đầu. Bình lắc có thể thay bằng lọ thủy tinh sạch có nắp kín.',
              ),
              LessonSection(
                title: 'Sắp xếp trước khi pha',
                body: 'Đọc công thức một lượt, rửa và lau khô dụng cụ, cân đong nguyên liệu rồi mới bắt đầu. Cách chuẩn bị này giúp thao tác liền mạch và hạn chế nhầm lẫn.',
              ),
            ],
            ingredients: ['Nước sạch để tráng dụng cụ'],
            tools: [
              'Ly đong hoặc cốc có vạch',
              'Thìa cán dài',
              'Dao nhỏ và thớt',
              'Lọ thủy tinh có nắp (thay bình lắc)',
            ],
            technique: 'Làm sạch bề mặt tiếp xúc với đồ uống; dùng thớt riêng cho trái cây và lau khô dụng cụ giữa các lần pha.',
            tips: [
              'Không dùng ly nứt hoặc có mùi chất tẩy rửa.',
              'Chuẩn bị khăn sạch để lau miệng ly trước khi phục vụ.',
            ],
          ),
          CourseLesson(
            id: 'bartending-flavor-balance',
            title: 'Cân bằng chua, ngọt và thơm',
            summary: 'Điều chỉnh vị đồ uống theo nguyên tắc thêm ít, nếm thử và tăng dần.',
            estimatedMinutes: 10,
            sections: [
              LessonSection(
                title: 'Bắt đầu với tỷ lệ dễ nhớ',
                body: 'Với đồ uống trái cây, hãy bắt đầu từ 2 phần nền trà hoặc nước ép, 1 phần vị chua và 1 phần chất tạo ngọt. Đây là điểm khởi đầu để nếm thử, không phải tỷ lệ bắt buộc cho mọi loại quả.',
              ),
              LessonSection(
                title: 'Nếm và hiệu chỉnh',
                body: 'Nếu vị gắt, thêm một ít nước nền; nếu nhạt, tăng nhẹ phần chua hoặc trà đậm; nếu chua quá, thêm siro từng 5 ml. Khuấy đều rồi nếm lại sau mỗi lần điều chỉnh.',
              ),
            ],
            ingredients: [
              'Nước cốt chanh',
              'Siro đường',
              'Trà hoặc nước ép trái cây',
            ],
            tools: ['Ly đong', 'Thìa khuấy', 'Ly nếm nhỏ'],
            technique: 'Đong theo ml để có thể lặp lại công thức; ghi lại lượng đã chỉnh thay vì rót trực tiếp từ chai.',
            tips: [
              'Nếm ở nhiệt độ gần với lúc phục vụ vì đá làm vị nhạt hơn.',
              'Trái cây chín tự nhiên đã ngọt, hãy giảm siro trước.',
            ],
          ),
        ],
      ),
      CourseChapter(
        title: 'Pha món đầu tiên',
        lessons: [
          CourseLesson(
            id: 'bartending-mojito',
            title: 'Mojito không cồn tại nhà',
            summary: 'Kết hợp chanh, bạc hà và soda để tạo một ly mocktail mát, thơm và cân bằng.',
            estimatedMinutes: 12,
            sections: [
              LessonSection(
                title: 'Chuẩn bị nguyên liệu',
                body: 'Dùng một quả chanh xanh cắt múi, khoảng 8 lá bạc hà, 2 thìa cà phê đường và 150 ml soda. Chuẩn bị thêm đá viên và một lát chanh để trang trí.',
              ),
              LessonSection(
                title: 'Hoàn thiện ly mojito',
                body: 'Cho chanh và đường vào ly, ép nhẹ để lấy nước. Thêm bạc hà và ấn rất nhẹ để giải phóng hương thơm, không nghiền nát lá. Cho đá gần đầy ly rồi rót soda từ từ.',
              ),
            ],
            ingredients: [
              '1 quả chanh xanh',
              '8 lá bạc hà',
              '2 thìa cà phê đường',
              '150 ml soda',
              'Đá viên',
            ],
            tools: ['Ly cao', 'Chày dầm hoặc cán thìa', 'Thìa khuấy'],
            technique: 'Dầm chanh trước, bạc hà sau và chỉ ấn nhẹ. Khuấy từ đáy lên để đường tan mà không làm mất bọt soda.',
            tips: [
              'Nếu không có chày dầm, dùng cán thìa sạch.',
              'Rót soda sau cùng để giữ bọt lâu hơn.',
            ],
          ),
        ],
      ),
    ],
  ),
  LearningCourse(
    id: 'fruit-tea-art',
    title: 'Nghệ thuật pha trà trái cây',
    description: 'Chọn trà, ủ đúng nhiệt độ và kết hợp trái cây tươi để ly trà trong, thơm dịu.',
    level: CourseLevel.intermediate,
    artwork: CourseArtworkType.fruitTea,
    chapters: [
      CourseChapter(
        title: 'Nền trà trong và thơm',
        lessons: [
          CourseLesson(
            id: 'fruit-tea-brewing',
            title: 'Chọn trà và kiểm soát nhiệt độ',
            summary: 'Hiểu sự khác nhau giữa trà đen, trà xanh và cách ủ để tránh vị chát.',
            estimatedMinutes: 9,
            sections: [
              LessonSection(
                title: 'Chọn nền trà',
                body: 'Trà đen có thân vị rõ, hợp với đào, cam và các loại siro. Trà xanh nhẹ hơn, phù hợp với chanh, vải hoặc trái cây có hương thanh.',
              ),
              LessonSection(
                title: 'Ủ đúng nhiệt',
                body: 'Trà đen thường ngon khi dùng nước khoảng 90–95°C trong 4–5 phút; trà xanh nên dùng nước khoảng 75–85°C trong 2–3 phút. Nếu không có nhiệt kế, để nước sôi nghỉ vài phút trước khi ủ trà xanh.',
              ),
            ],
            ingredients: ['3–5 g trà khô', '150 ml nước nóng'],
            tools: ['Ấm đun nước', 'Ấm hoặc cốc ủ', 'Rây lọc'],
            technique: 'Làm ấm ấm trà, đong lượng trà ổn định, canh giờ và lọc bã ngay khi đủ thời gian.',
            tips: [
              'Không ép hoặc vắt bã trà vì dễ làm nước trà đục và chát.',
              'Để trà nguội nhanh trong bình sạch trước khi thêm đá.',
            ],
          ),
          CourseLesson(
            id: 'fruit-tea-syrup',
            title: 'Sơ chế trái cây và làm nền vị',
            summary:
                'Giữ màu sắc và hương tươi của trái cây khi kết hợp với trà.',
            estimatedMinutes: 11,
            sections: [
              LessonSection(
                title: 'Sơ chế sạch và đồng đều',
                body: 'Rửa trái cây dưới vòi nước sạch, để ráo rồi cắt miếng vừa ăn. Dùng dao và thớt sạch; bỏ phần dập hoặc có mùi lạ.',
              ),
              LessonSection(
                title: 'Làm nền vị trái cây',
                body: 'Để trái cây ngâm tiết hương, trộn nhẹ với một lượng siro nhỏ trong 5–10 phút. Không nghiền quá mạnh các múi cam hoặc lát chanh vì tinh dầu ở vỏ có thể làm vị đắng.',
              ),
            ],
            ingredients: [
              'Trái cây tươi theo mùa',
              'Siro đường',
              'Một ít nước cốt chanh',
            ],
            tools: ['Dao và thớt sạch', 'Bát nhỏ', 'Ly đong'],
            technique: 'Cắt trái cây đồng đều, nếm thử trước khi thêm chanh và siro vào trà.',
            tips: [
              'Ưu tiên trái cây đang vào mùa để có hương vị tự nhiên.',
              'Bảo quản trái cây đã cắt trong hộp kín ở ngăn mát.',
            ],
          ),
        ],
      ),
      CourseChapter(
        title: 'Trà trái cây đặc trưng',
        lessons: [
          CourseLesson(
            id: 'fruit-tea-peach-orange',
            title: 'Trà đào cam sả',
            summary: 'Pha trà đen cùng đào, cam và sả theo từng lớp hương.',
            estimatedMinutes: 13,
            sections: [
              LessonSection(
                title: 'Pha phần trà nền',
                body: 'Ủ 4 g trà đen với 150 ml nước nóng trong 4 phút rồi lọc bã. Đập dập nhẹ một nhánh sả, cho vào trà khi trà còn ấm để hương sả lan đều.',
              ),
              LessonSection(
                title: 'Phối vị và phục vụ',
                body: 'Khi trà nguội, thêm 30 ml nước cam và 15 ml mật ong. Lắc cùng đá trong khoảng 8 giây, rót ra ly rồi thêm đào ngâm. Nếm trước khi tăng độ ngọt.',
              ),
            ],
            ingredients: [
              '150 ml trà đen',
              '3 miếng đào ngâm',
              '30 ml nước cam',
              '1 nhánh sả',
              '15 ml mật ong',
            ],
            tools: ['Ấm ủ trà', 'Rây lọc', 'Bình lắc hoặc lọ có nắp'],
            technique: 'Ủ trà đúng giờ, làm nguội trước khi thêm nước cam và chỉ lắc nhanh để đồ uống không bị loãng.',
            tips: [
              'Có thể dùng cam tươi vắt lấy nước nếu không có nước cam đóng chai.',
              'Đào ngâm thường đã ngọt; hãy nếm trước khi thêm mật ong.',
            ],
          ),
        ],
      ),
    ],
  ),
  LearningCourse(
    id: 'coffee-brewing-methods',
    title: 'Cà phê và các phương pháp pha chế',
    description: 'Khám phá cỡ xay, tỷ lệ nước và cách pha phin để kiểm soát độ đậm của cà phê.',
    level: CourseLevel.advanced,
    artwork: CourseArtworkType.coffee,
    chapters: [
      CourseChapter(
        title: 'Nền tảng chiết xuất',
        lessons: [
          CourseLesson(
            id: 'coffee-grind-ratio',
            title: 'Cỡ xay và tỷ lệ cà phê – nước',
            summary: 'Điều chỉnh cỡ xay và lượng nước để cà phê không quá loãng hoặc gắt.',
            estimatedMinutes: 10,
            sections: [
              LessonSection(
                title: 'Cỡ xay ảnh hưởng thế nào?',
                body: 'Bột quá mịn làm nước chảy chậm và dễ chiết xuất vị đắng; bột quá thô khiến nước chảy nhanh, vị thường mỏng và chua. Với phin gia đình, bắt đầu từ cỡ xay vừa rồi điều chỉnh theo tốc độ nhỏ giọt.',
              ),
              LessonSection(
                title: 'Ghi lại tỷ lệ',
                body: 'Thử 20–25 g cà phê với khoảng 70–90 ml nước nóng cho một phin nhỏ. Thay đổi một yếu tố mỗi lần, ghi lại lượng nước và thời gian để tìm ra vị phù hợp.',
              ),
            ],
            ingredients: ['20–25 g cà phê xay', '70–90 ml nước nóng'],
            tools: ['Cân bếp', 'Phin cà phê', 'Ấm đun nước'],
            technique: 'Làm ướt đều bột ở bước ủ, châm nước chậm và quan sát dòng nhỏ giọt.',
            tips: [
              'Bảo quản cà phê trong hộp kín, tránh nắng và hơi ẩm.',
              'Không thay đổi cỡ xay và tỷ lệ cùng lúc khi thử công thức.',
            ],
          ),
          CourseLesson(
            id: 'coffee-vietnamese-phin',
            title: 'Pha phin Việt Nam đúng nhịp',
            summary:
                'Thực hành các bước tráng phin, ủ cà phê và châm nước ổn định.',
            estimatedMinutes: 12,
            sections: [
              LessonSection(
                title: 'Làm nóng và nén nhẹ',
                body: 'Tráng phin và ly bằng nước nóng. Cho cà phê vào phin, lắc nhẹ để mặt bột phẳng rồi đặt nắp gài lên trên; chỉ nén vừa chạm, không ép chặt.',
              ),
              LessonSection(
                title: 'Ủ và châm nước',
                body: 'Rót khoảng 20 ml nước nóng để ủ trong 30 giây. Châm phần nước còn lại theo vòng tròn nhỏ, đậy nắp và để cà phê nhỏ giọt tự nhiên.',
              ),
            ],
            ingredients: ['25 g cà phê xay', '80 ml nước nóng'],
            tools: ['Phin cà phê', 'Ấm rót nước', 'Ly chịu nhiệt'],
            technique: 'Giữ lượng nước và tốc độ rót ổn định; thời gian nhỏ giọt khoảng 4–6 phút là điểm bắt đầu để đánh giá.',
            tips: [
              'Nước quá sôi có thể làm hương cà phê gắt; để nước nghỉ ngắn sau khi sôi.',
              'Nếu phin nhỏ giọt quá nhanh, thử xay mịn hơn một chút.',
            ],
          ),
        ],
      ),
      CourseChapter(
        title: 'Biến tấu thức uống cà phê',
        lessons: [
          CourseLesson(
            id: 'coffee-milk',
            title: 'Cà phê sữa đá cân bằng',
            summary: 'Kết hợp cà phê phin đậm với sữa đặc mà vẫn giữ được hương cà phê.',
            estimatedMinutes: 9,
            sections: [
              LessonSection(
                title: 'Pha và làm ngọt',
                body: 'Cho 25–30 ml sữa đặc vào ly. Pha phin trực tiếp lên trên hoặc khuấy cà phê nóng với sữa cho tan đều.',
              ),
              LessonSection(
                title: 'Điều chỉnh độ đậm',
                body: 'Thêm đá gần đầy ly, khuấy đều và nếm thử. Nếu quá ngọt, tăng phần cà phê ở lần pha sau; nếu vị gắt, giảm lượng cà phê hoặc rót chậm hơn.',
              ),
            ],
            ingredients: [
              '25 g cà phê xay',
              '80 ml nước nóng',
              '25–30 ml sữa đặc',
              'Đá viên',
            ],
            tools: ['Phin cà phê', 'Ly cao', 'Thìa khuấy'],
            technique: 'Hòa tan sữa khi cà phê còn nóng rồi mới thêm đá để vị đồng nhất.',
            tips: [
              'Dùng ly chịu nhiệt khi pha trực tiếp bằng phin.',
              'Thêm sữa từng ít một để giữ được vị cà phê mong muốn.',
            ],
          ),
        ],
      ),
    ],
  ),
];
