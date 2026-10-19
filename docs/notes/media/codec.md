# Codec

**Big picture:** a codec compresses pictures or samples into a bitstream and expands that bitstream again. The saved file is a container around one or more of those bitstreams.

Related: [Video codecs](video-codecs.md) · [Audio codecs](audio-codecs.md)

## Terms

Codec
: Coder–decoder. The method, and the program or chip that runs it, for compressing media and expanding it.

Encode
: Run the compressor. Frames or samples go in. A bitstream comes out.

Decode
: Run the decompressor. A bitstream goes in. Frames or samples a screen or speaker can play come out.

Bitstream
: The bytes a codec writes. An H.264 encoder writes bits an H.264 decoder reads. AAC bits need an AAC decoder.

Container
: The file format around the bitstreams, plus timing. MP4, MKV, and WebM are containers.

Bitrate
: Bits per second in a bitstream. A more efficient codec can hold a similar result at a lower bitrate, or spend the same bitrate on a larger picture.

Transcode
: Decode a bitstream to frames or samples, then encode those with another codec or other settings.

## Encode and decode

Encoding is the compress step. Decoding is the expand step. A player spends its time decoding. An export spends its time encoding.

A lossy codec, such as H.264 or AAC, discards detail while encoding. Decoding rebuilds a playable version. The discarded detail stays gone.

A lossless codec, such as FLAC, only packs the data tighter. Decoding restores the same samples that were encoded.

Changing codecs runs both steps. Decode the old bitstream, then encode with the new codec. That round trip is a transcode.

## Container

The container is the box. The codecs are what is inside it.

MP4 usually carries H.264 or HEVC video and AAC audio. MKV carries most pairs. WebM carries VP8, VP9, or AV1 video, with Vorbis or Opus audio.
