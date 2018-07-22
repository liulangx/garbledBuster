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
#判断输入参数是否唯一
getPara()
{
	if [ $1 -ne 1 ];then
		echo -e "\033[31m输入参数只能有一个！\033[0m";		
		exit -1;
	fi
}
#判断输入参数是否存在
isParaCorrect()
{
	if [ ! -f $1 -o -d $1 ];then
		echo -e "\033[31m输入文件或文件夹不存在！\033[0m";		
		exit -1;
	fi
}
#获取环境变量LANG指定的编码集
getCharset()
{
	strs=`locale | grep LANG= | tr "." "\n"`;
	for tmp in $strs
	do
		toCharset=$tmp;
	done
	#toCharset="UTF-8";
	echo -e "\033[32m当前编码集为$toCharset\033[0m";
}
#输入为文件时，转化编码格式
changeFile()
{
	echo -e "\033[32m输入为文件\033[0m";
	fromCharset=`file $fromFile | awk '{print $2}'`;
	
	fromWindow=`file $fromFile | grep -i -c crlf`;
	if [ $fromWindow ];then
		if [ $fromWindow -gt 0 ];then 
			echo -e "文件来源windows系统，装换中****";
			dos2unix $fromFile;
			echo -e "\033[32m文件转换到linux系统成功！\033[0m"
		fi
	fi
	if [ "$fromCharset"x = "ISO-8859"x ];then
		iconv -f GBK -t $toCharset $fromFile -o $fromFile;
		if [ $? -eq 0 ];then
			echo -e "\033[32m$fromFile转换成功\033[0m";
		else
			echo -e "\033[31m$fromFile转换失败\033[0m";
			exit -1;
		fi
	elif [ "$fromCharset"x = "$toCharset"x ];then
		echo -e "\033[32m$fromFile不需要转换！\033[0m";
	else
		iconv -f $fromCharset -t $toCharset $fromFile -o $fromFile;
		if [ $? -eq 0 ];then
			echo -e "\033[32m$fromFile转换成功\033[0m";
		else
			echo -e "\033[31m$fromFile转换失败\033[0m";
			exit -1;
		fi
	fi
}
#输入为文件夹时，转化编码格式
changeDir()
{
	echo -e "\032[32m输入为文件夹\033[0m";
	for file in `ls $1`
	do
		if [ -d $1"/"$file ];then
			changeDir $1"/"$file;
		else
			tmpFile=$1"/"$file;
			tmpFromCharset=`file $tmpFile | awk '{print $2}'`;
			tmpFromWindow=`file $tmpFile | grep -i -c crlf`;
			if [ $tmpFromWindow -gt 0 ];then
				echo -e "文件来源windows系统，装换中****";
				dos2unix $tmpFile;
				echo -e "\033[32m$tmpFile文件转换到linux系统成功！\033[0m"
			fi
			if [ "$tmpFromCharset"x = "ISO-8859"x ];then
				iconv -f GBK -t $toCharset $tmpFile -o $tmpFile;
				if [ $? -eq 0 ];then
					echo -e "\033[32m$tmpFile转换成功\033[0m";
				else
					echo -e "\033[31m$tmpFile转换失败\033[0m";
					exit -1;
				fi
			elif [ "$tmpFromCharset"x = "$toCharset"x ];then
				echo -e "\033[32m$tmpFile不需要转换！\033[0m";
			else
				iconv -f $tmpFromCharset -t $toCharset $tmpFile -o $tmpFile;
				if [ $? -eq 0 ];then
					echo -e "\033[32m$tmpFile转换成功\033[0m";
				else
					echo -e "\033[31m$tmpFile转换失败\033[0m";
					exit -1;
				fi
			fi
		fi
	done
}
#主函数
main()
{
	#判断脚本是否从主脚本执行的
	isExcuteFromMainShell;
	#判断是否是1个参数
	getPara $#;
	#判断参数是否为文件或者文件夹
	isParaCorrect $1;
	#获取LANG中的编码集,存储到了toCharset中；
	getCharset; 
	fromFile=$1;
	fromFile=${fromFile%*/};
	#need#
	echo $fromFile;
	if [ -f $fromFile ];then #文件
		changeFile;
	else #文件夹
		changeDir $fromFile;
	fi	
	exit 0;
}

main $@;
