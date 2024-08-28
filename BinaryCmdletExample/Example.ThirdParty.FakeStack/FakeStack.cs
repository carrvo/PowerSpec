using Example.Specification;
using System;
using System.Collections;

namespace Example.ThirdParty
{
    public sealed class FakeStack<T> : Queue, IStack<T>
    {
        public T Pop() => (T)this.Dequeue();

        public void Push(T item) => this.Enqueue(item);

        T IStack<T>.Peek() => (T)this.Peek();
    }
}
