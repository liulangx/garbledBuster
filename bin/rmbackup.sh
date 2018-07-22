#该函数应该为执行的最后一个操作。删除备份的文件
main()
{
	if [ $# -ne 0 ];then
		for tmpFile in $@
		{
			rm -r $tmpFile".intbak";
		}
		echo "true" > $logFile;
		echo -e "\033[32m删除备份成功！\033[0m";
	fi
	exit 0;
}
main $@;