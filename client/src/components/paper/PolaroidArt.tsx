import React from 'react';

interface PolaroidArtProps {
  image?: string;
  title: string;
  artist: string;
  className?: string;
  tiltAngle?: number;
}

export const PolaroidArt: React.FC<PolaroidArtProps> = ({
  image,
  title,
  artist,
  className = '',
  tiltAngle = -1.2,
}) => {
  return (
    <div
      className={`relative inline-block bg-paper2 p-3 pb-5 rounded-[2px] shadow-paper transition-transform duration-300 hover:rotate-0 ${className}`}
      style={{
        transform: `rotate(${tiltAngle}deg)`,
      }}
    >
      {/* Semi-transparent tape strip */}
      <div className="polaroid-tape" aria-hidden="true" />

      {/* Image container with desaturated paper aesthetic */}
      <div className="w-48 h-48 sm:w-56 sm:h-56 overflow-hidden rounded-[2px] bg-desk relative">
        {image ? (
          <img
            src={image}
            alt={`${title} by ${artist}`}
            className="w-full h-full object-cover grayscale-[15%] contrast-[1.05]"
            loading="lazy"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-gradient-to-tr from-desk to-paper text-muted text-xs font-mono">
            FOLIO ART
          </div>
        )}
      </div>

      <div className="mt-3 px-1 text-center">
        <h4 className="font-serif font-semibold text-text text-sm truncate max-w-[200px]">
          {title}
        </h4>
        <p className="text-muted text-xs truncate max-w-[200px] mt-0.5">
          {artist}
        </p>
      </div>
    </div>
  );
};
