// Copyright (c) 2021 Sho Kuroda <krdlab@gmail.com>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import { atom, selector } from 'recoil';

export type Item = {
  id: number;
  text: string;
  isComplete: boolean;
};

export const FilterState = {
  ShowAll: 'Show All',
  ShowCompleted: 'Show Completed',
  ShowUncompleted: 'Show Uncompleted',
} as const;
export type FilterStateType = typeof FilterState[keyof typeof FilterState];

export const todoListState = atom<Item[]>({
  key: 'todoListState',
  default: [],
});

export const todoListFilterState = atom<FilterStateType>({
  key: 'todoListFilterState',
  default: 'Show All',
});

export const filteredTodoListState = selector({
  key: 'filtertedTodoListState',
  get: ({ get }) => {
    const list = get(todoListState);
    const filter = get(todoListFilterState);
    switch (filter) {
      case 'Show Completed':
        return list.filter((i) => i.isComplete);
      case 'Show Uncompleted':
        return list.filter((i) => !i.isComplete);
      default:
        return list;
    }
  },
});

export const todoListStatsState = selector({
  key: 'todoListStatsState',
  get: ({ get }) => {
    const todoList = get(todoListState);
    const totalNum = todoList.length;
    const totalCompletedNum = todoList.filter((i) => i.isComplete).length;
    const totalUncompletedNum = totalNum - totalCompletedNum;
    const percentCompleted = totalNum === 0 ? 0 : (totalCompletedNum / totalNum) * 100;
    return {
      totalNum,
      totalCompletedNum,
      totalUncompletedNum,
      percentCompleted,
    };
  },
});
