void api_end(void);

void FkjsMain(void)
{
	*((char *) 0x00102600) = 0;
	api_end();
}
