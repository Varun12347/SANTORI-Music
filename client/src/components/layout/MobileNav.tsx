import React from 'react';
import { Compass, Home, Library, Sliders } from 'lucide-react';
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
    <nav className="md:hidden fixed top-0 left-0 right-0 z-40 bg-paper/95 backdrop-blur-sm border-b border-rule flex items-center justify-around h-12 px-2 shadow-sm">
      <button
        onClick={() => onNavigate('home')}
        className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-xs font-medium transition-colors ${
          currentPage === 'home' ? 'text-ink font-semibold border-b-2 border-ink' : 'text-muted'
        }`}
      >
        <Home className="w-4 h-4" />
        <span>Home</span>
      </button>

      <button
        onClick={() => onNavigate('search')}
        className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-xs font-medium transition-colors ${
          currentPage === 'search' ? 'text-ink font-semibold border-b-2 border-ink' : 'text-muted'
        }`}
      >
        <Compass className="w-4 h-4" />
        <span>Search</span>
      </button>

      <button
        onClick={() => onNavigate('library')}
        className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-xs font-medium transition-colors ${
          currentPage === 'library' ? 'text-ink font-semibold border-b-2 border-ink' : 'text-muted'
        }`}
      >
        <Library className="w-4 h-4" />
        <span>Library</span>
      </button>

      <button
        onClick={onOpenSettings}
        className="flex items-center space-x-1.5 px-3 py-1.5 rounded text-xs text-muted hover:text-ink transition-colors"
        title="Open desk settings"
      >
        <Sliders className="w-4 h-4" />
        <span>Desk</span>
      </button>
    </nav>
  );
};
