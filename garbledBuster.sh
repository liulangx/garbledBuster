#!/bin/bash
#变量声明,此处export是为了防呆设计，保证用户不执行下层脚本
export dstWelFile="/etc/motd";
export logFile="garbledBuster.log";
export SHELLPATH="./bin/";

#红色模板
#echo -e "\033[31m\033[0m";
#绿色模板
#echo -e "\033[32m\033[0m";
#黄色模板
#echo -e "\033[33m\033[0m";

#判断是否需要恢复数据
needRecoverOrNot()
{
	$SHELLPATH"garbledRecover.sh"
	if [ $? -ne 0 ];then
		echo -e "\033[31m恢复过程失败！请检查$logFile格式是否正确！\033[0m";
		exit -1;
	fi
}
#至少需要一个输入
moreThanOnePara()
{
	if [ $1 -eq 0 ];then
		echo -e "\033[31m至少需要一个输入！\033[0m";
		exit -1;
	fi
}
#判断是否有多余参数
isThereAnyUselessPara()
{
	if [ $paraCount -ne 0 ];then 
		echo -e "\033[31m输入错误，请输入正确的参数！-h查看用法！\033[0m"
		exit -1;
	fi
}
#输入参数组合错误
paraError()
{
	echo -e "\033[31m输入参数过多！\033[0m";
	exit -1;
}

ftBackUp()
{
	#备份过程
	if [ -f $fParameter -a -f $tParameter ];then
		tmpFiles="$fParameter $tParameter ";
		for tmpFile in `awk 'print $1' $fParameter`
		{
			foundFilename=false;
			if [ ! -f $tmpFile ];then
				echo -e "\033[31m-f指定文件中有非文件项！\033[0m";
				exit -1;
			fi
			if [ $tmpFiles ];then
				for tmpFileComp in tmpFiles
				{
					if [ "$tmpFile"x = "$tmpFileComp"x ];
						foundFilename=true;
						break;
					fi
				}
			fi
			if [ "$foundFilename"x = "false"x ];then
				echo -e "\033[33m$tmpFile\033[0m";
				tmpFiles="$tmpFiles$tmpFile ";
			fi
		}
		for tmpFile in `awk 'print $1' $tParameter`
		{
			foundFilename=false;
			if [ ! -f $tmpFile ];then
				echo -e "\033[31m-f指定文件中有非文件项！\033[0m";
				exit -1;
			fi
			if [ $tmpFiles ];then
				for tmpFileComp in tmpFiles
				{
					if [ "$tmpFile"x = "$tmpFileComp"x ];
						echo -e "\033[31m-t指定文件中有重复项！\033[0m";
						exit -1;
					fi
				}
			fi
			if [ "$foundFilename"x = "false"x ];then
				echo -e "\033[33m$tmpFile\033[0m";
				tmpFiles="$tmpFiles$tmpFile ";
			fi
		}
		#need#
		echo $tmpFiles;
		$SHELLPATH"backup.sh -ft $tmpFiles";
	else
		echo -e "\033[31m输入不正确！请检查！\033[0m";
		exit -1;
	fi
}
#删除备份
ftRmBackup()
{
	$SHELLPATH"rmbackup.sh $tmpFiles";
	if [ $? -ne 0 ];then
		echo -e "\033[31m删除备份失败！\033[0m";
		exit -1;
	fi
}

#确定是否超过两个option，超过属于错误，返回-1；
isOptionsNumberRight()
{
	if [ $count -gt 2 ];then
		paraError
	fi
}
#获取参数
getParameter()
{
	count=0;
	while getopts d:rF:f:t:h opt
	do
		case "$opt" in
		#f means format, 通过shell LANG定义的编码格式来格式化文件
		F)
		FParaExsit=yes;
		FParameter=$OPTARG;
		let count++;
		;;
		d)
		dParaExsit=yes;
		dParameter=$OPTARG;
		let count++;
		;;
		r)
		rParaExsit=yes;
		let count++;
		;;
		f)
		fParaExsit=yes;
		fParameter=$OPTARG;
		let count++;
		;;
		t)
		tParaExsit=yes;
		tParameter=$OPTARG;
		let count++;
		;;
		h)
		hParaExsit=yes;
		let count++;
		;;
		*)
		echo -e "\033[31mUnkown option: $opt\033[0m"
		exit -1;
		;;
		esac
	done
	#echo $OPTIND;
	isOptionsNumberRight;
}

#输出帮助信息
dispHelpInformation()
{
	echo -e "\033[32m\t-h\t\t\tShowUsage显示用法\033[0m";
	echo -e "\033[32m\t-r\t\t\tRecover welcome message. Use it in Suse linux!/恢复登录界面信息。仅供suse系统使用！\033[0m";
	echo -e "\033[32m\t-d file\t\t\tChange welcome message. Use it in Suse linux!/修改登录界面信息。仅供suse系统使用！\033[0m";
	echo -e "\033[32m\t-F para\t\t\tAccording to shell charset env to change files' charset.\n\t\t\t\t根据当前系统环境变量更改文件的编码格式。\033[0m";
	echo -e "\033[32m\t-f paraT\t\t将paraF文件中指定的文件内容插入到paraT文件中指定文件的指定位置。\033[0m\n\t\t示例：\n\t\tparaF文件中内容为\n\t\t\tinput1.txt 2 4\n\t\t\tinput2.txt 20 24\n\t\tparaT中内容为\n\t\t\toutput1.txt 2\n\t\t\toutput2.txt 4\n\t\t表明将input1.tx中2-4行和input2.txt中20-24行的内容添加到output1.txt第2行和output2.txt第4行后";
	exit 0;
}

#获取h参数，输出帮助信息
get_hAndDispUsage()
{
	if [ "$hParaExsit"x = "yes"x ];then
		dispHelpInformation;
		if [ $? -eq 0 ];then
			exit 0;
		else
			exit -1;
		fi
	fi
}

#获取F参数，并将其编码转换为shell环境编码集
get_FAndFormatFiles()
{
	if [ "$FParaExsit"x = "yes"x -a -f $FParameter ];then
		while true
		do
			echo -e "\033[32m请确保输入的文件或者文件夹中包含的文件均为文本档案【继续（yes）/放弃（no）】？\033[0m";
			read confirm;
			if [ "$confirm"x = "no"x ];then
				exit -1;
			elif [ "$confirm"x = "yes"x ];then 
				break;
			fi
		done
		#need#
		#echo $FParameter;
		FParameter=${FParameter%*/};
		#备份操作
		$SHELLPATH"backup.sh" -F $FParameter;
		echo -e "\033[32m****开始转换****\033[0m";
		$SHELLPATH"transToEnvCharset.sh" $FParameter;
		if [ $? -eq 0 ];then
			echo -e "\033[32m****转换成功****\033[0m";
		else
			echo -e "\033[31m****转换失败****\033[0m";
			exit -1;
		fi
		#将备份删除
		$SHELLPATH"rmbackup.sh" $FParameter;
		exit 0;
	fi
}
#获取d参数，并将输入参数对应文件内容传入系统欢迎界面文件中
get_dAndChgWelMessage()
{
	if [ "$dParaExsit"x = "yes"x -a -f $dParameter ];then
		if [ $UID -ne 0 ];then
			echo -e "\033[31m权限不够，必须提供管理员权限！使用sudo重试！\033[0m";
			echo "true" > $logFile;
			exit -1;
		fi
		#备份操作
		$SHELLPATH"backup.sh" -d $dParameter;
		$SHELLPATH"chgWelcomeMessage.sh" $FParameter;
		if [ $? -eq 0 ];then
			echo -e "\033[32m****修改登录界面信息成功****\033[0m";
		else
			echo -e "\033[31m****修改登录界面信息失败****\033[0m";
			exit -1;
		fi
		#将备份删除
		$SHELLPATH"rmbackup.sh" $dParameter;
		exit 0;
	fi
}
#获取r参数，还原系统欢迎界面文件
get_rAndChgWelMessage()
{
	if [ "$rParaExsit"x = "yes"x ];then
		if [ $UID -ne 0 ];then
			echo -e "\033[31m权限不够，必须提供管理员权限！使用sudo重试！\033[0m";
			echo "true" > $logFile;
			exit -1;
		fi
		#备份操作
		$SHELLPATH"backup.sh" -d;
		$SHELLPATH"chgWelcomeMessage.sh" -r;
		if [ $? -eq 0 ];then
			echo -e "\033[32m****还原登录界面信息成功****\033[0m";
		else
			echo -e "\033[31m****还原登录界面信息失败****\033[0m";
			exit -1;
		fi
		#将备份删除
		$SHELLPATH"rmbackup.sh";
		exit 0;
	fi
}
#获取ft参数，合并文件
get_ftAndMergeFiles()
{
	if [ "$fParaExsit"x = "yes"x -a "$tParaExsit"x = "yes"x ];then
		while true
		do
			echo -e "\033[32m请确保该命令中用到的所有文件档案都是文本档案，并且命令格式为档案名或者档案名.类型名[继续（yes）/放弃（no）]？\033[0m";
			read confirm;
			if [ "$confirm"x = "no"x ];then
				exit -1;
			elif [ "$confirm"x = "yes"x ];then 
				break;
			fi
		done
		#备份
		ftBackUp;
		#执行合并操作
		$SHELLPATH"mergeFiles.sh $fParameter $tParameter";
		if [ $? -eq 0 ];then
			echo -e "\033[32m****合并成功****\033[0m";
		else
			echo -e "\033[31m****合并失败****\033[0m";
			exit -1;
		fi
		#删除备份
		ftRmBackup;
		exit 0;
	fi
}

main()
{
	#判断是否需要恢复数据
	needRecoverOrNot;
	#判断是否输入
	moreThanOnePara $#;
	#获取参数
	getParameter $@;
	#echo $OPTIND;
	shift $[$OPTIND - 1];
	paraCount=$#;
	#need#
	#echo $paraCount;
	#判断是否有多余参数
	isThereAnyUselessPara;
	#****************************下面执行的每个函数如果执行成功都应该返回exit 0，如果没有任何一个函数返回，那么则证明输入参数有错误的组合，如-f -d、-f -r等类型的组合错误**************
	#获取h参数，输入帮助信息
	get_hAndDispUsage
	#获取F参数，并将其编码转换为shell环境编码集
	get_FAndFormatFiles;
	#获取d参数，并将输入参数对应文件内容传入系统欢迎界面文件中
	get_dAndChgWelMessage;
	#获取r参数，还原系统欢迎界面文件中
	get_rAndChgWelMessage;
	#获取ft参数，还原系统欢迎界面文件中
	get_ftAndMergeFiles;
	#输入参数组合错误
	paraError;
}

main $@;
