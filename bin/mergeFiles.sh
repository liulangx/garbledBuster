#!/bin/bash
#判断脚本是否从主脚本执行的
isExcuteFromMainShell()
{
	if [ ! $dstWelFile -a $logFile ];then
		echo -e "\033[31m必须从程序的入口脚本执行！\033[0m";
		exit -1;
	fi
	if [ ! $SHELLPATH ];then
		echo -e "\033[31m必须从程序的入口脚本执行！\033[0m";
		exit -1;
	fi
}
#判断输入是否为2个
isTwoParamters()
{
	if [ $# -ne 2 ];then 
		echo -e "\033[31m输入应该是两个！用法：$0 originalFile targetFile\033[0m";
		exit -1;
	fi
}

main()
{
	#判断脚本是否从主脚本执行的
	isExcuteFromMainShell;
	isTwoParamters $@;

	fParameter=$1;
	tParameter=$2;
	awk -f $SHELLPATH"awkOriSed.awk" $fParameter;
	if [ $? -ne 0 ];then
		echo -e "\033[31mError: 输入文件有误！\033[0m";
		exit -1;
	fi
	awk -f $SHELLPATH"awkTarSed.awk" $tParameter;
	if [ $? -ne 0 ];then
		echo -e "\033[31mError: 输入文件有误！\033[0m";
		exit -1;
	fi
	echo -e "\033[32mError: 成功\033[0m";
}
main $@;