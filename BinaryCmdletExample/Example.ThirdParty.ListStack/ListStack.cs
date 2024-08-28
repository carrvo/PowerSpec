using Example.Specification;
using System;
using System.Collections.Generic;

namespace Example.ThirdParty
{
    public sealed class ListStack<T> : List<T>, IStack<T>
    {
        public T Peek() => this[this.Count - 1];

        public T Pop()
        {
            Int32 endIndex = this.Count - 1;
            T item = this[endIndex];
            this.RemoveAt(endIndex);
            return item;
        }

        public void Push(T item) => this.Add(item);
    }
}
