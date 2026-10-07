enum class Months {
    January = 1,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
};

class Data {
private:
    int day = 0;
    int month = 0;
    int year = 0;

    void ApplyStandartValue()
    {
        day = 1;
        month = 1;
        year = 1970;
    }

    void Normalize()
    {
        if ((year < 1970 || year > 2099) ||
            (month < 1 || month > 12) ||
            (day < 1 || day > 31))
        {
            ApplyStandartValue();
            return;
        }

        if ((month == static_cast<int>(Months::September) ||
            month == static_cast<int>(Months::April) ||
            month == static_cast<int>(Months::November) ||
            month == static_cast<int>(Months::June)) &&
            (day == 31))
        {
            ApplyStandartValue();
            return;
        }

        if (month == static_cast<int>(Months::February))
        {
            if ((year % 4 == 0) || (year % 400 == 0))
            {
                if (day > 29)
                {
                    ApplyStandartValue();
                    return;
                }
            } else
            {
                if (day > 28)
                {
                    ApplyStandartValue();
                    return;
                }
            }
        }
    }

public:
    Data(int d, int m, int y) :
        day(d),
        month(m),
        year(y)
    {
        Normalize();
    }

    int GetDay() const { return day; }
    int GetMonth() const { return month; }
    int GetYear() const { return year; }

/*     Data operator+(int d) const
    {

    } */

    /* int operator-(Data d) const
    {

    } */
};

#include <iostream>

int main()
{
    Data d(29, 2, 2026);

    std::cout << d.GetDay() << "\n"
        << d.GetMonth() << "\n"
        << d.GetYear() << "\n";

    return 0;
}