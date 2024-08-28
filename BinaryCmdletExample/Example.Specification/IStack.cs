using System;

namespace Example.Specification
{
    public interface IStack<T>
    {
        void Push(T item);

        T Pop();

        T Peek();

        Int32 Count { get; }
    }
}
