#include<graphics.h>
#include<time.h>
#include<conio.h>

#define High 1000
#define Width 1000  //设置画布大小
#define Charsize 25 //设置字体大小
#define Highnum High/Charsize
#define Widthnum Width/Charsize

/***产生随机字母个数与随机字母,形成含有字母信息的矩阵***/
void random_char(char char_rain[Widthnum][Highnum],int Color[Widthnum],int Cnum[Widthnum])
{
	for (int i = 0; i < Widthnum; i++)
	{
		Cnum[i] = rand() % (Highnum); //每行随机字符个数
		for (int j = 0; j < Cnum[i]; j++)
		{
			char_rain[i][j] = (rand() % 26) + 65;//产生A~Z的ascall码
		}
		Color[i] = 255;//初始化颜色
	}
}

/***字符雨下落与更新**/
void rain_drop(char char_rain[Widthnum][Highnum], int Cnum[Widthnum],int Color[Widthnum])
{
	for (int i = 0; i < Widthnum; i++)
	{
		if (Cnum[i] < Highnum)
		{
			for (int j = Cnum[i]-1;j>=0; j--)//注意j=Cnum[i]-1,否则可能溢出
			{
				char_rain[i][j + 1] = char_rain[i][j]; //向下移动一格
			}
			Cnum[i]++; //字符个数加一
			char_rain[i][0] = (rand() % 26) + 65; //第一行再随机产生一个字符
		}
		else
		{
			if (Color[i] > 40)
				Color[i] -= 20;  //颜色逐渐变淡
			else
			{
				Cnum[i]= rand() % (Highnum);
				Color[i] = (rand()%75)+180;
				for (int m = 0; m < Cnum[i]; m++)
				{
					char_rain[i][m] = (rand() % 26) + 65;
				}
			}// 颜色太淡,重新产生一列
		}
	}
}

/***显示画面***/
void show(char char_rain[Widthnum][Highnum],int Color[Widthnum], int Cnum[Widthnum])
{
	settextstyle(25,10, _T("宋体"));// 设置字体格式
	for (int i = 0; i < Widthnum; i++)
	{
		int x = i * Charsize;//横坐标
		for (int j = 0; j <Cnum[i]; j++)
		{
			int y = j * Charsize;//纵坐标
			setcolor(RGB(0, Color[i], 0));
			outtextxy(x, y, char_rain[i][j]);
		}
	}
	FlushBatchDraw();
	Sleep(100);
}
int main(void)
{
	initgraph(High, Width);
	char char_rain[Widthnum][Highnum];//存字符信息
	int Cnum[Widthnum];//存有每列的字符个数信息
	int Color[Widthnum];//存每列颜色信息

	srand((unsigned)time(NULL)); //设置随机数种子,避免重复产生相同数字
	random_char(char_rain,Color,Cnum);
	BeginBatchDraw();
	while (1)
	{
		rain_drop(char_rain, Cnum, Color);
		show(char_rain, Color,Cnum);
	}
	EndBatchDraw();
	_getch();
	closegraph();
}
