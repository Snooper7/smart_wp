# Input initial data(Вводим начальные данные)

$title = Read-Host 'Input title'
$dbuser = Read-Host 'Input database username'
$dbpassword = Read-Host 'Input database password'
$dbname = Read-Host 'Input database name'
$git = Read-Host 'Input Git path'

# Download Wordpress and delete git binding(Скачиваем Wordpress и удаляем связь с github)

git clone git://core.git.wordpress.org/ $title
rmdir $title\.git -Force -Recurse -Confirm:$false

# Delete all default themes(Удаляем все дефолтные темы)
Remove-Item $title\wp-content\themes\* -Force -Recurse -Confirm:$false

# Go to project directory and install Timber(Переходим в папку темы и устанавливаем стартовую тему Timber)

cd $title\wp-content\themes\
composer create-project timber/learn-timber-theme $title

# Go to theme dir and install fronend environment(Переходим в тему и создаем папку для верстки и скачиваем туда стартовый шаблон)

cd $title
mkdir frontend
cd frontend
git clone git@github.com:Vyatka-IT/start-frontend.git .
rmdir .git -Force -Recurse -Confirm:$false


# Install gulp(Устанавливаем Gulp в папке для верстки)
npm install

# Создаем базу данных с именем проекта. Надо скачать коннектор https://dev.mysql.com/downloads/connector/net/

[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")
$connStr ="server=localhost;Persist Security Info=false;user id=$dbuser; pwd=$dbpassword;"
$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)
$conn.Open()

$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.Connection  = $conn

$cmd.CommandText = 'CREATE SCHEMA `' + $dbname + '`'

$cmd.ExecuteNonQuery()

# Return to wp-content dir and init the git(Возвращаемся в папку wp-content и запускаем гит)

cd ..\..\..

git init

# Create file .gitignore(Создаем файл .gitignore)

New-Item -Path . -Name ".gitignore" -ItemType "file"
Add-Content -Path .gitignore -Exclude help* -Value '/wp-content/themes/tasteofquality/resources/node_modules/*'
Add-Content -Path .gitignore -Exclude help* -Value '/cache/*'
Add-Content -Path .gitignore -Exclude help* -Value '/logs/*'
Add-Content -Path .gitignore -Exclude help* -Value 'debug.log'

# Create directory for db dump files(Создаем папку для дампов базы данных)

mkdir db

# Make first commit (Делаем первый коммит)

$d = Get-Date
git add .
git commit -m "$d"

# Connect the remote repo and firest push(Подключаем удаленный репозиторий и делаем первый пуш)

git remote add origin $git
git branch -M main
git push -u origin main