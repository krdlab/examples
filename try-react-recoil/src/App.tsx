import React from 'react';
import './App.css';
import { RecoilRoot } from 'recoil';
import { CharacterCounter } from './CharacterCounter';
import { TodoList } from './TodoList';

function App() {
  return (
    <RecoilRoot>
      <CharacterCounter />
      <TodoList />
    </RecoilRoot>
  );
}

export default App;
