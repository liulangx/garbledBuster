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

#判断日志文件是true还是false，true跳过恢复，false让用户确定是否回退。
judgeLogFileTrueOrFalse()
{
	#当前读取行数
	n=1;
	falseMark=`cat $logFile | sed -n "${n}p" | awk '{print $1}'`;
	if [ "$falseMark"x = "false"x ];then
		while true
		do
			echo -e "\033[32m文件不正常终止，是否需要恢复[恢复（yes）/放弃（no）]?\033[0m";
			read confirm;
			if [ "$confirm"x = "no"x ];then
				exit -1;
			elif [ "$confirm"x = "yes"x ];then
				break;
			fi
		done
		recover;
	elif [ "$falseMark"x = "true"x ];then
		exit 0;
	else 
		echo -e "\033[31m日志文件格式不正确！请检查$logFile\033[0m";
		exit -1;
	fi
}

recover()
{
	n=2;
	paraType=`cat $logFile | sed -n "${n}p" | awk '{print $1}'`;
	#need #
	#echo "$paraType";
	if [ "$paraType"x = "-F"x ];then
		recover_F;
	elif [ "$paraType"x = "-d"x ];then
		recover_d;
	elif [ "$paraType"x = "-ft"x ];then
		recover_ft;
	elif [ "$paraType"x = "-r"x ];then
		recover_r;
	fi
}
#日志中参数为-F的恢复过程
recover_F()
{
	n=3;
	parameter=`cat $logFile | sed -n "${n}p" | awk '{print $1}'`;
	parameter=${parameter%*/};
	#need #
	#echo $parameter;
	if [ ! -f $parameter".intbak" ];then
		if [ ! -d $parameter".intbak" ];then
			echo -e "\033[32m恢复成功！1.指令执行成功。2.源文件未改动。\033[0m";
			echo "true" > $logFile;
			exit 0;
		fi
	fi
	if [ -d $parameter".intbak" -o -f $parameter".intbak" ];then
		timeBak=`stat -c %Y $parameter".intbak"`;
		timeOri=`stat -c %Y $parameter`;
		if [ $timeBak -lt $timeOri ];then
			mv -r $parameter".intbak" $parameter;
			echo -e "\033[32m编码转换源文件恢复到执行前状态成功！\033[0m";
			echo "true" > $logFile;
			exit 0;
		else
			rm -r $parameter".intbak";
			echo -e "\033[32m编码转换源文件恢复成功！\033[0m";
			echo "true" > $logFile;
			exit 0;
		fi
	fi
}
recover_d()
{
	if [ $UID -ne 0 ];then
		echo -e "\033[31m权限不够，必须提供管理员权限！使用sudo重试！\033[0m";
		exit -1;
	fi
	n=3;
	parameter=`cat $logFile | sed -n "${n}p" | awk '{print $1}'`;
	#need #
	#echo $parameter;
	if [ ! -f $parameter".intbak" ];then
		echo -e "\033[32m恢复成功！1.指令执行成功。2.源文件未改动。\033[0m";
		echo "true" > $logFile;
		exit 0;
	fi
	if [ -f $parameter".intbak" ];then
		timeBak=`stat -c %Y $parameter".intbak"`;
		timeOri=`stat -c %Y $parameter`;
		if [ $timeBak -lt $timeOri ];then
			mv -r $parameter".intbak" $parameter;
			echo -e "\033[32m恢复到执行前状态成功！\033[0m";
			echo "true" > $logFile;
			exit 0;
		else
			rm -r $parameter".intbak";
			echo -e "\033[32m恢复成功！\033[0m";
			echo "true" > $logFile;
			exit 0;
		fi
	fi
}
#日志中参数为-ft的恢复过程
recover_ft()
{
	n=3;
	parameter=`cat $logFile | sed -n "${n}p" | awk '{print $0}'`;
	#need #
	#echo $parameter;
	for tmpParameter in parameter
	do
		if [ ! -f $tmpParameter".intbak" ];then
				echo -e "\033[32m$tmpParameter恢复成功！1.指令执行成功。2.源文件未改动。\033[0m";
		fi
		if [ -f $tmpParameter".intbak" ];then
			tmpTimeBak=`stat -c %Y $tmpParameter".intbak"`;
			tmpTimeOri=`stat -c %Y $tmpParameter`;
			if [ $tmpTimeBak -lt $tmpTimeOri ];then
				mv -r $tmpParameter".intbak" $tmpParameter;
				echo -e "\033[32m$tmpParameter恢复到执行前状态成功！\033[0m";
			else
				rm -r $tmpParameter".intbak";
				echo -e "\033[32m$tmpParameter恢复成功！\033[0m";
			fi
		fi
	done
	echo -e "\033[32m恢复成功！\033[0m";
	echo "true" > $logFile;
	exit 0;
}
#日志中参数为-r的恢复过程
recover_r()
{
	if [ $UID -ne 0 ];then
		echo -e "\033[31m权限不够，必须提供管理员权限！使用sudo重试！\033[0m";
		exit -1;
	fi
	$SHELLPATH"chgWelComeMessage.sh" -r;
	if [ $? -eq 0 ];then
		echo "true" > $logFile;
		echo -e "\033[32m执行该脚本前的欢迎界面信息恢复成功！\033[0m";
		exit 0;
	else
		echo -e "\033[31m执行该脚本前的欢迎界面信息恢复失败！\033[0m";
		exit -1;
	fi
}
main()
{
	#判断脚本是否从主脚本执行的
	isExcuteFromMainShell;
	#判断日志文件是true还是false，true跳过恢复，false让用户确定是否回退。
	judgeLogFileTrueOrFalse;
	#还原
	recover;
}
main;