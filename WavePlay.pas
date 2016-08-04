unit WavePlay;

interface

uses
  MMSystem, MMIOWrap, WaveWrap;

    type
        tAudio_waveform = class
            Header : TWaveHdr;
            Data   : pAnsichar;
            Format : TWaveFormatEx;

            destructor Destroy; override;

            function Read(
              const Filename : string
              ) : boolean;
            procedure Play;
            end;

implementation

    uses
        SysUtils, Forms, Dialogs;

    destructor tAudio_waveform.Destroy;
        begin
            strDispose(Data);
              { ...which was set to nil automatically by
                Delphi, since it is a pointer field of
                a class structure. }
            end;

    function tAudio_waveform.Read(
      const Filename : string
      ) : boolean;
        var
            Parent_chunk_info,
            Chunk_info         : TMMCKInfo;
        begin
            result := false;
            strDispose(Data);
            Data := nil;
            with tMMIO_file.Create do
                try
                    Open(Filename);

                    { Find the "WAVE" audio Parent Chunk. }
                    FourChars(Parent_chunk_info.fccType) := 'WAVE';
                    First_descend(Parent_chunk_info,MMIO_FINDRIFF);

                    { Find the "fmt " format chunk. }
                    FourChars(Chunk_info.ckid) := 'fmt ';
                    Descend(Chunk_info,Parent_chunk_info,MMIO_FINDCHUNK);

                    { Read PCM wave format record. }
                    Read(@Format,Chunk_info.ckSize);
                      { Here, we could instantiate a tWave_device
                        and do a WAVE_FORMAT_QUERY to see if we are
                        able to handle the wave format, and whether
                        we should go any fuurther. }

                    { Go back up to the WAVE level, and then find
                      the "data" chunk. }
                    Ascend(Chunk_info);
                    FourChars(Chunk_info.ckid) := 'data';
                    Descend(Chunk_info,Parent_chunk_info,MMIO_FINDCHUNK);

                    { Allocate the wave data buffer, and read it in. }
                    Data := AnsiStrAlloc(Chunk_info.ckSize);
                    Read(Data,Chunk_info.ckSize);

                    { Fill in the Wave_header }
                    with Header do begin
                        lpData         := Data;
                        dwBufferLength := Chunk_info.ckSize;
                        dwFlags        := 0;
                        dwLoops        := 0;
                        end;
                    result:= true;
                  finally
                    Free;
                  end;
            end;

    procedure tAudio_waveform.Play;
        begin
            with tWave_device.Create do
                try
                    Open(Format,WAVE_FORMAT_QUERY);
                      { Die here if we can't handle the format. }
                    Open(Format,0);
                    Prepare_header(Header);
                    Write(Header);
                    while (Header.dwFlags and WHDR_DONE) = 0 do;
            //            Application.ProcessMessages;
                    Unprepare_header(Header);
                    Close;
                  finally
                    Free;
                  end;
            end;

{initialization}
    end.

