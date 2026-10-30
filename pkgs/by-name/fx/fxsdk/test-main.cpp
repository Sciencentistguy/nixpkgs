#include <gint/display.h>
#include <gint/keyboard.h>

#include <algorithm>
#include <memory>
#include <string>
#include <vector>

int main()
{
	std::vector<int> values{3, 1, 2};
	std::sort(values.begin(), values.end());

	auto label = std::make_unique<std::string>("smallest: ");
	*label += std::to_string(values.front());

	dclear(C_WHITE);
	dtext(1, 1, C_BLACK, label->c_str());
	dupdate();

	getkey();
	return 1;
}
