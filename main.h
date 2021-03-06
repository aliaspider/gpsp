/* gameplaySP
 *
 * Copyright (C) 2006 Exophase <exophase@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef MAIN_H
#define MAIN_H

typedef enum
{
  TIMER_INACTIVE,
  TIMER_PRESCALE,
  TIMER_CASCADE
} timer_status_type;

typedef enum
{
  TIMER_NO_IRQ,
  TIMER_TRIGGER_IRQ
} timer_irq_type;


typedef enum
{
  TIMER_DS_CHANNEL_NONE,
  TIMER_DS_CHANNEL_A,
  TIMER_DS_CHANNEL_B,
  TIMER_DS_CHANNEL_BOTH
} timer_ds_channel_type;

typedef struct
{
  s32 count;
  u32 reload;
  u32 prescale;
  u32 stop_cpu_ticks;
  fixed8_24 frequency_step;
  timer_ds_channel_type direct_sound_channels;
  timer_irq_type irq;
  timer_status_type status;
} timer_type;

typedef enum
{
  auto_frameskip,
  manual_frameskip,
  no_frameskip
} frameskip_type;

extern u32 cpu_ticks;
extern u32 frame_ticks;
extern u32 execute_cycles;
extern frameskip_type current_frameskip_type;
extern u32 frameskip_value;
extern u32 random_skip;
extern u32 global_cycles_per_instruction;
extern u32 synchronize_flag;
extern u32 skip_next_frame;

extern u32 cycle_memory_access;
extern u32 cycle_pc_relative_access;
extern u32 cycle_sp_relative_access;
extern u32 cycle_block_memory_access;
extern u32 cycle_block_memory_sp_access;
extern u32 cycle_block_memory_words;
extern u32 cycle_dma16_words;
extern u32 cycle_dma32_words;
extern u32 flush_ram_count;

extern u64 base_timestamp;

extern char main_path[512];

extern u32 update_backup_flag;

u32 update_gba();
void reset_gba();
#ifdef __LIBRETRO__
#define synchronize()
void init_main();
#else
void synchronize();
#endif
void quit();
void delay_us(u32 us_count);
void get_ticks_us(u64 *tick_return);
void game_name_ext(char *src, char *buffer, char *extension);
void main_write_mem_savestate(file_tag_type savestate_file);
void main_read_savestate(file_tag_type savestate_file);


#ifdef PSP_BUILD

u32 file_length(char *filename, s32 dummy);

#else

u32 file_length(const char *dummy, FILE *fp);

#endif

extern u32 real_frame_count;
extern u32 virtual_frame_count;
extern u32 max_frameskip;
extern u32 num_skipped_frames;

void change_ext(const char *src, char *buffer, const char *extension);
void make_rpath(char *buff, size_t size, const char *ext);

#endif


