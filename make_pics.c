#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>
#include <stdbool.h>
#include <limits.h>

#define NROWS 96
#define NCOLS 63
#define IMG_BUFSIZE NROWS * NCOLS

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

int main(void)
{
	loadbuf(&global_img);
	maskbuf(&global_img, 8);
	write_pics(global_pics, &global_img);
	char name[] = "out/pic0.bin";
	for (int i = 0; i < 7; ++i) {
		++(name[7]);
		FILE *fil = fopen(name, "w");
		assert(fil != NULL && "failed to open for writing");
		size_t nwritten = fwrite(global_pics[i].buf, 1, 12 * NCOLS, fil);
		assert(nwritten == 12 * NCOLS);
		fclose(fil);
	}
}
