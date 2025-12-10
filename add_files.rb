require 'xcodeproj'

# 프로젝트 열기
project_path = 'JakBu/JakBu.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 메인 타겟 가져오기
target = project.targets.first

# JakBu 그룹 찾기
main_group = project.main_group.find_subpath('JakBu', true)

# Presentation 그룹 생성 또는 찾기
presentation_group = main_group.find_subpath('Presentation', true)

# 하위 그룹들 생성
onboarding_group = presentation_group.new_group('Onboarding')
auth_group = presentation_group.new_group('Auth')
main_view_group = presentation_group.new_group('Main')

# 파일 추가 함수
def add_file_to_project(group, file_path, target)
  file_ref = group.new_reference(file_path)
  target.add_file_references([file_ref])
end

# 파일들 추가
add_file_to_project(onboarding_group, 'JakBu/Presentation/Onboarding/OnboardingViewController.swift', target)
add_file_to_project(auth_group, 'JakBu/Presentation/Auth/AuthViewController.swift', target)
add_file_to_project(main_view_group, 'JakBu/Presentation/Main/MainTabBarController.swift', target)
add_file_to_project(main_view_group, 'JakBu/Presentation/Main/HomeViewController.swift', target)
add_file_to_project(main_view_group, 'JakBu/Presentation/Main/CalendarViewController.swift', target)

# 프로젝트 저장
project.save

puts "파일들이 성공적으로 추가되었습니다!"
