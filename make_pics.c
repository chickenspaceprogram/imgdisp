#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>
#include <stdbool.h>
#include <limits.h>
#include <inttypes.h>

#define NROWS 96
#define NCOLS 64
#define IMG_BUFSIZE NROWS * NCOLS
#define DATA_HDR_SZ 17
#define FINAL_PIC_SIZE 12 * NCOLS

static_assert(CHAR_BIT == 8, "your char bit is dumb");

struct in_img {
	uint8_t buf[IMG_BUFSIZE];
};

struct pic {
	uint8_t buf[12 * NCOLS];
};

void zero_pic(struct pic *pic) {
	memset(pic->buf, 0, 12 * NCOLS);
}

void set_pic_bit(struct pic *pic, size_t ind) {
	pic->buf[ind / 8] |= 1 << (7 - (ind % 8));
}

void write_pics(struct pic *pics, const struct in_img *masked_img)
{
	for (size_t i = 0; i < IMG_BUFSIZE; ++i) {
		for (size_t j = 0; j < masked_img->buf[i]; ++j) {
			set_pic_bit(pics + j, i);
		}
	}
}

static struct in_img global_img;

static void loadbuf(struct in_img *img)
{
	size_t res = fread(img->buf, 1, IMG_BUFSIZE, stdin);
	assert(res == IMG_BUFSIZE);
}

// num_gscale_imgs must be a power of 2
static void maskbuf(struct in_img *img, size_t num_gscale_imgs)
{
	size_t chunksize = 0x100 / num_gscale_imgs;
	for (size_t i = 0; i < IMG_BUFSIZE; ++i) {
		img->buf[i] = img->buf[i] / chunksize;
	}
}

static struct pic global_pics[7] = {};

static void print_filhdr(FILE *fil, uint16_t data_sect_len)
{
	int retval = fwrite("**TI83F*\x1a\x0a\x00", 1, 11, fil);
	assert(retval == 11);

	retval = fwrite("From chickenspaceprogram's bad-apple prgm ", 1, 42, fil);
	assert(retval == 42);

	retval = putc(0xFF & data_sect_len, fil);
	assert(retval != EOF);
	putc((0xFF00 & data_sect_len) >> 8, fil);
	assert(retval != EOF);
}

static void print_datahdr(FILE *fil, uint16_t datalen, uint16_t *cksum)
{
	uint8_t buf[] = {
		0x0d, 0x00,
		datalen & 0xFF, (datalen & 0xFF00) >> 8,
		0x15, // typeid
		'I', 'M', 'G', 'D', 'I', 'S', 'P', '1',
		0x00, // version
		0x00, // in ram
		datalen & 0xFF, (datalen & 0xFF00) >> 8,
	};
	size_t res = fwrite(buf, 1, sizeof(buf), fil);
	assert(res == sizeof(buf));
	for (size_t i = 0; i < sizeof(buf); ++i) {
		*cksum += buf[i];
	}
	// pic len
}

static void add_cksum(uint8_t *buf, size_t bufsz, uint16_t *cksum)
{
	for (size_t i = 0; i < bufsz; ++i) {
		*cksum += buf[i];
	}
}

#define DATA_SZ (FINAL_PIC_SIZE * 7 + 5)

static void fwrite_pic(struct pic *pic, uint16_t *cksum, FILE *fil)
{
	size_t nwritten = fwrite(pic->buf, 1, FINAL_PIC_SIZE, fil);
	assert(nwritten == FINAL_PIC_SIZE);
	add_cksum(pic->buf, FINAL_PIC_SIZE, cksum);
}

int main(void)
{
	loadbuf(&global_img);
	maskbuf(&global_img, 8);
	write_pics(global_pics, &global_img);
	const char *name = "IMGDISP1.8xv";
	FILE *fil = fopen(name, "w");
	assert(fil != NULL && "failed to open for writing");
	print_filhdr(fil, DATA_SZ + DATA_HDR_SZ);
	uint16_t cksum = 0;
	print_datahdr(fil, DATA_SZ, &cksum);
	// magic nums
	fputc(0x69, fil);
	fputc(0x6d, fil);
	fputc(0x67, fil);
	fputc(0x64, fil);
	fputc(0x00, fil);
	cksum += 0x69;
	cksum += 0x6d;
	cksum += 0x67;
	cksum += 0x64;
	cksum += 0x00;

	fwrite_pic(global_pics, &cksum, fil);
	fwrite_pic(global_pics + 6, &cksum, fil);
	fwrite_pic(global_pics + 1, &cksum, fil);
	fwrite_pic(global_pics + 5, &cksum, fil);
	fwrite_pic(global_pics + 2, &cksum, fil);
	fwrite_pic(global_pics + 4, &cksum, fil);
	fwrite_pic(global_pics + 3, &cksum, fil);

//	for (int i = 0; i < 7; ++i) {
//		size_t nwritten = fwrite(global_pics[i].buf, 1, FINAL_PIC_SIZE, fil);
//		assert(nwritten == FINAL_PIC_SIZE);
//		add_cksum(global_pics[i].buf, FINAL_PIC_SIZE, &cksum);
//	}
	putc(cksum & 0xFF, fil);
	putc((cksum & 0xFF00) >> 8, fil);
	fclose(fil);
}
