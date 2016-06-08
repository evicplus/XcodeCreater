#!/bin/bash -e

#判断当前文件路径是否存在
if [[ "${BASH_SOURCE[0]}" == "" || "${BASH_SOURCE[0]}" == "/dev"* ]] ; then
	RUNNING_LOCALLY=false
	TMPDIR=`mktemp -d /tmp/ios-starter.XXXXXX`	
else
	RUNNING_LOCALLY=true
	TMPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi


#应该判断一下当前目录下有没有输入的文件夹 如果存在则 mkdir会报错
echo -n "Application Name (e.g. 'MyApplication' with no spaces will be created in current dir)? "
read PROJECT_NAME

##增加判断文件夹是否存在
#http://xiaxue777.blog.163.com/blog/static/30406733201310181114917/
if [ -d "$PROJECT_NAME" ]; then
	echo "❗❗❗️: Folder already existed in current path"
else 
	mkdir "$PROJECT_NAME"

	#跳转到创建的文件夹下
	cd "$PROJECT_NAME"

	##复制文件 -f 强行复制文件或者目录 无论是否存在 -r 递归
	#应该根据自己的工程修改这部分内容
	cp -fr $TMPDIR/Demo \
	$TMPDIR/Demo.xcodeproj \
	$TMPDIR/DemoTests \
	$TMPDIR/DemoUITests \
	.

	##替换工程中的参数
	sed -i "" s/Demo.app\\/Demo/$PROJECT_NAME.app\\/$PROJECT_NAME/g Demo.xcodeproj/project.pbxproj
	sed -i "" s/Demo.app/$PROJECT_NAME.app/g Demo.xcodeproj/project.pbxproj
	sed -i "" s/Info.plist/Info.plist/g Demo.xcodeproj/project.pbxproj
	sed -i "" s/Demo-Prefix.pch/$PROJECT_NAME-Prefix.pch/g Demo.xcodeproj/project.pbxproj
	sed -i "" "s/= Demo/= $PROJECT_NAME/g" Demo.xcodeproj/project.pbxproj
	sed -i "" "s/Demo/$PROJECT_NAME/g" Demo.xcodeproj/project.pbxproj

	#重命名工程
	mv -f Demo.xcodeproj "$PROJECT_NAME.xcodeproj"
	cd "$PROJECT_NAME.xcodeproj"
	rm -rf xcuserdata
	rm -rf project.xcworkspace/xcuserdata
	cd ..

	mv -f Demo $PROJECT_NAME
	rm -rf Demo

	#修改Prefix文件
	cd $PROJECT_NAME
	mv Demo-Prefix.pch $PROJECT_NAME-Prefix.pch
	cd ..

	#修改单元测试
	cd DemoTests
	sed -i "" s/DemoTests/$PROJECT_NAME"Tests"/g DemoTests.m
	mv DemoTests.m $PROJECT_NAME"Tests.m"
	cd ..
	mv -f DemoTests $PROJECT_NAME"Tests"
	rm -rf DemoTests

	#修改UITest
	cd DemoUITests
	sed -i "" s/DemoUITests/$PROJECT_NAME"UITests"/g DemoUITests.m
	mv DemoUITests.m $PROJECT_NAME"UITests.m"
	cd ..
	mv -f DemoUITests $PROJECT_NAME"UITests"
	rm -rf DemoUITests

	#初始化 Pod
	pod init
	pod --no-repo-update install
	echo "✅✅✅Success! Launching $PROJECT_NAME"
	open $PROJECT_NAME.xcworkspace

fi
