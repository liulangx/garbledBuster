#!/bin/bash
# change or recover welcome message from /etc/motd
oriFile="/etc/motd.bak";
dstFile="/etc/motd";

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
#获取参数
getParameter()
{
	count=0;
	while getopts r opt
	do
		case "$opt" in
		r)
		rParaExsit=yes;
		let count++;
		;;
		*)
		echo -e "\033[31mUnkown option: $opt\033[0m"
		exit -1;
		;;
		esac
	done
}

getPara_r()
{
	echo -e "\033[32m****开始****\033[0m";
	if [ -f $oriFile ];then
		echo -e "\033[32m****恢复中****\033[0m";
		mv $oriFile $dstFile;
		echo -e "\033[32m****恢复完成****\033[0m";
	else
		echo -e "\033[32m****恢复文件不存在，无需恢复！****\033[0m";
	fi
	exit 0;
}

backupSystemWelcomeMessFile()
{
	if [ ! -f $oriFile ]then
		echo -e "\033[32m备份系统欢迎界面消息文件$dstFile\033[0m";
		cp $dstFile $oriFile;
		echo -e "\033[32m备份系统欢迎界面消息文件$dstFile完成\033[0m";
	fi
}

getParaFile()
{
	fileName=$1;
	#备份系统欢迎消息文件
	backupSystemWelcomeMessFile;
	if [ $? -eq 0 ];then
		echo -e "\033[32m拷贝$fileName内容到$motd中\033[0m";
		cat $fileName > $dstFile;
		echo -e "\033[32m成功\033[0m";
		exit 0;
	else
		echo -e "\033[32m备份系统欢迎界面消息文件$dstFile失败\033[0m";
		exit -1;
	fi
}

main()
{
	#判断脚本是否从主脚本执行的
	isExcuteFromMainShell;
	getParameter;
	shift $[$OPTIND - 1];
	if [ "$rParaExsit"x = "yes"x];then
		if [ $# -eq 0 ];then 
			getPara_r;
		else
			echo -e "\033[31m输入参数数量有误,此时不应该有非OPTION参数033[0m";
			exit -1;
		fi
	else
		if [ $# -eq 1 ];then 
			if [ -f $1 ];then
				getParaFile $1;
			else
				echo -e "\033[31m输入参数对应文件不存在033[0m";
				exit -1;
			fi
		else
			echo -e "\033[31m输入参数数量有误033，此时应该有一个非OPTION参数[0m";
			exit -1;
		fi
	fi
	
}
main $@;