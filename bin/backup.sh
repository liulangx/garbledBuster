#为文件执行备份操作，拷贝文件，让拷贝文件和源文件的修改时间一致，为了判断是否有恢复的必要
main()
{
	#文件的存在性检查应该交由上层结构确定
	echo "false" > $logFile;
	echo "$1" >> $logFile;
	shift 1;
	if [ $# -ne 0 ];then
		result="";
		for tmpFile in $@
		do
			result=$result$tmpFile" ";
		done
		result=${result%?}; #去掉最后一个空格
		echo "$result" >> $logFile;
		for tmpFile in $@
		{
			if [ -f $tmpFile ];then
				cp $tmpFile $tmpFile".intbak";
				touch $tmpFile $tmpFile".intbak";
			elif [ -d $tmpFile ];then
				cp -r $tmpFile $tmpFile".intbak";
				find $tmpFile $tmpFile".intbak" | xargs touch;
			else
				echo -e "\033[31mThis should not trigerred by users! 备份失败！\033[0m";
				exit -1;
			fi
		}
	fi
	echo -e "\033[32m备份成功\033[0m";
}
main $@;