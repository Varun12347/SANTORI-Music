import React, { useEffect, useState } from 'react';
import { DeskSettingsDrawer } from './components/drawers/DeskSettingsDrawer';
import { MobileNav } from './components/layout/MobileNav';
import { PlayerBar } from './components/layout/PlayerBar';
import { Sidebar } from './components/layout/Sidebar';
import type { PageView } from './components/layout/Sidebar';
import { AudioProvider } from './context/AudioContext';
import { ThemeProvider } from './context/ThemeContext';
import { HomePage } from './pages/HomePage';
import { LibraryPage } from './pages/LibraryPage';
import { SearchPage } from './pages/SearchPage';
import { NowPlayingPage } from './pages/NowPlayingPage';

const PAGE_PATHS: Record<PageView, string> = {
  home: '/',
  search: '/search',
  library: '/library',
  player: '/player',
};

const pageFromPath = (): PageView => {
  const path = window.location.pathname.replace(/\/+$/, '') || '/';
  const match = (Object.entries(PAGE_PATHS) as [PageView, string][]).find(([, route]) => route === path);
  return match?.[0] || 'home';
};

export const App: React.FC = () => {
  const [currentPage, setCurrentPage] = useState<PageView>(pageFromPath);
  const [isSettingsOpen, setIsSettingsOpen] = useState<boolean>(false);

  useEffect(() => {
    const handlePopState = () => setCurrentPage(pageFromPath());
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const navigate = (page: PageView) => {
    const path = PAGE_PATHS[page];
    if (window.location.pathname !== path) window.history.pushState({}, '', path);
    setCurrentPage(page);
  };

  return (
    <ThemeProvider>
      <AudioProvider>
        <div className="min-h-screen bg-desk text-text flex flex-col relative select-none">
          {/* Top Mobile Bar */}
          <MobileNav
            currentPage={currentPage}
            onNavigate={navigate}
            onOpenSettings={() => setIsSettingsOpen(true)}
          />

          {/* Main Workspace Layout */}
          <div className="flex-1 flex pt-12 md:pt-0 pb-24">
            {/* Left Sidebar */}
            <Sidebar
              currentPage={currentPage}
              onNavigate={navigate}
              onOpenSettings={() => setIsSettingsOpen(true)}
            />

            {/* Central Content Canvas */}
            <main className="flex-1 p-4 md:p-8 max-w-7xl mx-auto w-full overflow-y-auto">
              {currentPage === 'home' && <HomePage />}
              {currentPage === 'search' && <SearchPage />}
              {currentPage === 'library' && <LibraryPage />}
              {currentPage === 'player' && <NowPlayingPage onBack={() => navigate('home')} />}
            </main>
          </div>

          {/* Fixed Bottom Player Bar */}
          <PlayerBar onOpenPlayer={() => navigate('player')} />

          {/* Desk Settings Slide-in Drawer */}
          <DeskSettingsDrawer
            isOpen={isSettingsOpen}
            onClose={() => setIsSettingsOpen(false)}
          />
        </div>
      </AudioProvider>
    </ThemeProvider>
  );
};

export default App;
