import React from 'react';

interface RubberStampProps {
  label?: string;
  className?: string;
}

export const RubberStamp: React.FC<RubberStampProps> = ({
  label = 'LIKED',
  className = '',
}) => {
  return (
    <div
      className={`rubber-stamp ${className}`}
      title="Track saved to liked list"
    >
      {label}
    </div>
  );
};
