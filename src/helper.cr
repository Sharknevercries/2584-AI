macro max(a, b)
    __temp1 = {{a}}
    __temp2 = {{b}}
    if __temp1 > __temp2
      __temp1
    else
      __temp2
    end
  end
