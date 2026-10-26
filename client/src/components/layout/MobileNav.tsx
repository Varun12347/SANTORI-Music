import React from 'react';
import { AudioLines, Compass, Home, Library, Sliders } from 'lucide-react';
import type { PageView } from './Sidebar';

interface MobileNavProps {
  currentPage: PageView;
  onNavigate: (page: PageView) => void;
  onOpenSettings: () => void;
}

export const MobileNav: React.FC<MobileNavProps> = ({
  currentPage,
  onNavigate,
  onOpenSettings,
}) => {
  return (
    <nav className="md:hidden fixed top-0 left-0 right-0 z-40 bg-paper/95 backdrop-blur-sm border-b border-rule flex items-center justify-between h-12 px-1.5 shadow-sm">
      <button
        onClick={() => onNavigate('home')}
        className={`flex min-w-0 flex-1 items-center justify-center gap-1 px-1.5 py-1.5 rounded text-xs font-medium transition-colors ${
          currentPage === 'home' ? 'text-ink font-semibold border-b-2 border-ink' : 'text-muted'
        }`}
        aria-label="Home"
      >
        <Home className="w-4 h-4" />
        <span className="max-[420px]:hidden">Home</span>
      </button>

      <button
        onClick={() => onNavigate('search')}
        className={`flex min-w-0 flex-1 items-center justify-center gap-1 px-1.5 py-1.5 rounded text-xs font-medium transition-colors ${
          currentPage === 'search' ? 'text-ink font-semibold border-b-2 border-ink' : 'text-muted'
        }`}
        aria-label="Search"
      >
        <Compass className="w-4 h-4" />
        <span className="max-[420px]:hidden">Search</span>
      </button>

      <button
        onClick={() => onNavigate('library')}
        className={`flex min-w-0 flex-1 items-center justify-center gap-1 px-1.5 py-1.5 rounded text-xs font-medium transition-colors ${
          currentPage === 'library' ? 'text-ink font-semibold border-b-2 border-ink' : 'text-muted'
        }`}
        aria-label="Your library"
      >
        <Library className="w-4 h-4" />
        <span className="max-[420px]:hidden">Library</span>
      </button>

      <button
        onClick={() => onNavigate('player')}
        className={`flex min-w-0 flex-1 items-center justify-center gap-1 px-1.5 py-1.5 rounded text-xs font-medium transition-colors ${
          currentPage === 'player' ? 'text-ink font-semibold border-b-2 border-ink' : 'text-muted'
        }`}
        aria-label="Now playing"
      >
        <AudioLines className="w-4 h-4" />
        <span className="max-[420px]:hidden">Player</span>
      </button>

      <button
        onClick={onOpenSettings}
        className="flex min-w-0 flex-1 items-center justify-center gap-1 px-1.5 py-1.5 rounded text-xs text-muted hover:text-ink transition-colors"
        title="Open desk settings"
        aria-label="Open desk settings"
      >
        <Sliders className="w-4 h-4" />
        <span className="max-[420px]:hidden">Desk</span>
      </button>
    </nav>
  );
};
