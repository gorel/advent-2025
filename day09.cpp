#include <cstdio>
#include <iostream>
#include <vector>

struct Point {
  int64_t x;
  int64_t y;
};

int64_t cross(Point p1, Point p2, Point p3) {
    return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x);
}

bool onSegment(const Point& a, const Point& b, const Point& p) {
    return std::fabs(cross(a,b,p)) < 1e-12 &&
           (p.x - std::min(a.x,b.x)) >= -1e-12 &&
           (p.x - std::max(a.x,b.x)) <= 1e-12 &&
           (p.y - std::min(a.y,b.y)) >= -1e-12 &&
           (p.y - std::max(a.y,b.y)) <= 1e-12;
}

bool segmentsIntersect(const Point& a, const Point& b,
                       const Point& c, const Point& d) 
{
    double d1 = cross(a, b, c);
    double d2 = cross(a, b, d);
    double d3 = cross(c, d, a);
    double d4 = cross(c, d, b);

    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)))
        return true;

    if (std::fabs(d1) < 1e-12 && onSegment(a, b, c)) return true;
    if (std::fabs(d2) < 1e-12 && onSegment(a, b, d)) return true;
    if (std::fabs(d3) < 1e-12 && onSegment(c, d, a)) return true;
    if (std::fabs(d4) < 1e-12 && onSegment(c, d, b)) return true;

    return false;
}

bool pointInPolygon(const std::vector<Point>& poly, const Point& p) {
    bool inside = false;
    int n = poly.size();
    for (int i = 0, j = n - 1; i < n; j = i++) {
        const Point &a = poly[j], &b = poly[i];

        if (onSegment(a, b, p)) return true; // on boundary = inside

        bool cond = ((a.y > p.y) != (b.y > p.y)) &&
                    (p.x < (b.x - a.x) * (p.y - a.y) /
                                (b.y - a.y + 1e-12) + a.x);
        if (cond)
            inside = !inside;
    }
    return inside;
}

bool rectangleInsideHull(const std::vector<Point>& hull,
                         const std::vector<Point>& rect) {
    // 1. Check rectangle points inside hull
    for (const auto& p : rect) {
        if (!pointInPolygon(hull, p))
            return false;
    }

    // 2. Check rectangle edges don't cross hull edges
    int hn = hull.size();
    int rn = rect.size();

    for (int i = 0; i < rn; i++) {
        Point r1 = rect[i];
        Point r2 = rect[(i + 1) % rn];

        for (int j = 0; j < hn; j++) {
            Point h1 = hull[j];
            Point h2 = hull[(j + 1) % hn];

            // Allow edges touching (intersection at endpoints)
            if (segmentsIntersect(r1, r2, h1, h2)) {
                // If intersection is *not only* touching inside, reject
                if (!onSegment(r1, r2, h1) && !onSegment(r1, r2, h2) &&
                    !onSegment(h1, h2, r1) && !onSegment(h1, h2, r2))
                    return false;
            }
        }
    }

    return true;
}

bool valid(const std::vector<Point>& bounds, const Point& p1, const Point& p2) {
  auto xMin = std::min(p1.x, p2.x);
  auto xMax = std::max(p1.x, p2.x);
  auto yMin = std::min(p1.y, p2.y);
  auto yMax = std::max(p1.y, p2.y);

  auto bottomLeft = Point{xMin, yMin};
  auto bottomRight = Point{xMax, yMin};
  auto topLeft = Point{xMin, yMax};
  auto topRight = Point{xMax, yMax};

  std::vector<Point> rect{bottomLeft, bottomRight, topRight, topLeft};
  return rectangleInsideHull(bounds, rect);
}

int main(int argc, char** argv) {
  std::vector<Point> points;
  for (std::string line; std::getline(std::cin, line); /* empty */) {
    Point p;
    sscanf(line.c_str(), "%lld,%lld\n", &p.x, &p.y);
    points.push_back(p);
  }

  int64_t part1 = 0;
  int64_t part2 = 0;
  for (size_t i = 0; i < points.size() - 1; ++i) {
    const auto& p1 = points[i];
    for (size_t j = i+1; j < points.size(); ++j) {
      const auto& p2 = points[j];
      auto dx = std::abs(p1.x - p2.x) + 1;
      auto dy = std::abs(p1.y - p2.y) + 1;
      part1 = std::max(part1, dx * dy);
      part2 = std::max(part2, valid(points, p1, p2) ? dx * dy : -1);
    }
  }

  std::cout << "Part 1: " << part1 << '\n';
  std::cout << "Part 2: " << part2 << '\n';

  return 0;
}
