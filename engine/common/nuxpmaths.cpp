//#include "stdafx.h"
#include "nuxptypes.h"
#include "../renderer/nurenderer.h"

namespace Nuclear
{
	const float FIRE_SIN[181] =
	{
		sinf(TORADIANS(0)), sinf(TORADIANS(1)), sinf(TORADIANS(2)), sinf(TORADIANS(3)), sinf(TORADIANS(4)),
		sinf(TORADIANS(5)), sinf(TORADIANS(6)), sinf(TORADIANS(7)), sinf(TORADIANS(8)), sinf(TORADIANS(9)),
		sinf(TORADIANS(10)), sinf(TORADIANS(11)), sinf(TORADIANS(12)), sinf(TORADIANS(13)), sinf(TORADIANS(14)),
		sinf(TORADIANS(15)), sinf(TORADIANS(16)), sinf(TORADIANS(17)), sinf(TORADIANS(18)), sinf(TORADIANS(19)),
		sinf(TORADIANS(20)), sinf(TORADIANS(21)), sinf(TORADIANS(22)), sinf(TORADIANS(23)), sinf(TORADIANS(24)),
		sinf(TORADIANS(25)), sinf(TORADIANS(26)), sinf(TORADIANS(27)), sinf(TORADIANS(28)), sinf(TORADIANS(29)),
		sinf(TORADIANS(30)), sinf(TORADIANS(31)), sinf(TORADIANS(32)), sinf(TORADIANS(33)), sinf(TORADIANS(34)),
		sinf(TORADIANS(35)), sinf(TORADIANS(36)), sinf(TORADIANS(37)), sinf(TORADIANS(38)), sinf(TORADIANS(39)),
		sinf(TORADIANS(40)), sinf(TORADIANS(41)), sinf(TORADIANS(42)), sinf(TORADIANS(43)), sinf(TORADIANS(44)),
		sinf(TORADIANS(45)), sinf(TORADIANS(46)), sinf(TORADIANS(47)), sinf(TORADIANS(48)), sinf(TORADIANS(49)),
		sinf(TORADIANS(50)), sinf(TORADIANS(51)), sinf(TORADIANS(52)), sinf(TORADIANS(53)), sinf(TORADIANS(54)),
		sinf(TORADIANS(55)), sinf(TORADIANS(56)), sinf(TORADIANS(57)), sinf(TORADIANS(58)), sinf(TORADIANS(59)),
		sinf(TORADIANS(60)), sinf(TORADIANS(61)), sinf(TORADIANS(62)), sinf(TORADIANS(63)), sinf(TORADIANS(64)),
		sinf(TORADIANS(65)), sinf(TORADIANS(66)), sinf(TORADIANS(67)), sinf(TORADIANS(68)), sinf(TORADIANS(69)),
		sinf(TORADIANS(70)), sinf(TORADIANS(71)), sinf(TORADIANS(72)), sinf(TORADIANS(73)), sinf(TORADIANS(74)),
		sinf(TORADIANS(75)), sinf(TORADIANS(76)), sinf(TORADIANS(77)), sinf(TORADIANS(78)), sinf(TORADIANS(79)),
		sinf(TORADIANS(80)), sinf(TORADIANS(81)), sinf(TORADIANS(82)), sinf(TORADIANS(83)), sinf(TORADIANS(84)),
		sinf(TORADIANS(85)), sinf(TORADIANS(86)), sinf(TORADIANS(87)), sinf(TORADIANS(88)), sinf(TORADIANS(89)),
		sinf(TORADIANS(90)), sinf(TORADIANS(91)), sinf(TORADIANS(92)), sinf(TORADIANS(93)),	sinf(TORADIANS(94)),
		sinf(TORADIANS(95)), sinf(TORADIANS(96 )),sinf(TORADIANS(97 )),sinf(TORADIANS(98 )),sinf(TORADIANS(99 )),
		sinf(TORADIANS(100)),sinf(TORADIANS(101)),sinf(TORADIANS(102)),sinf(TORADIANS(103)),sinf(TORADIANS(104)),
		sinf(TORADIANS(105)),sinf(TORADIANS(106)),sinf(TORADIANS(107)),sinf(TORADIANS(108)),sinf(TORADIANS(109)),
		sinf(TORADIANS(110)),sinf(TORADIANS(111)),sinf(TORADIANS(112)),sinf(TORADIANS(113)),sinf(TORADIANS(114)),
		sinf(TORADIANS(115)),sinf(TORADIANS(116)),sinf(TORADIANS(117)),sinf(TORADIANS(118)),sinf(TORADIANS(119)),
		sinf(TORADIANS(120)),sinf(TORADIANS(121)),sinf(TORADIANS(122)),sinf(TORADIANS(123)),sinf(TORADIANS(124)),
		sinf(TORADIANS(125)),sinf(TORADIANS(126)),sinf(TORADIANS(127)),sinf(TORADIANS(128)),sinf(TORADIANS(129)),
		sinf(TORADIANS(130)),sinf(TORADIANS(131)),sinf(TORADIANS(132)),sinf(TORADIANS(133)),sinf(TORADIANS(134)),
		sinf(TORADIANS(135)),sinf(TORADIANS(136)),sinf(TORADIANS(137)),sinf(TORADIANS(138)),sinf(TORADIANS(139)),
		sinf(TORADIANS(140)),sinf(TORADIANS(141)),sinf(TORADIANS(142)),sinf(TORADIANS(143)),sinf(TORADIANS(144)),
		sinf(TORADIANS(145)),sinf(TORADIANS(146)),sinf(TORADIANS(147)),sinf(TORADIANS(148)),sinf(TORADIANS(149)),
		sinf(TORADIANS(150)),sinf(TORADIANS(151)),sinf(TORADIANS(152)),sinf(TORADIANS(153)),sinf(TORADIANS(154)),
		sinf(TORADIANS(155)),sinf(TORADIANS(156)),sinf(TORADIANS(157)),sinf(TORADIANS(158)),sinf(TORADIANS(159)),
		sinf(TORADIANS(160)),sinf(TORADIANS(161)),sinf(TORADIANS(162)),sinf(TORADIANS(163)),sinf(TORADIANS(164)),
		sinf(TORADIANS(165)),sinf(TORADIANS(166)),sinf(TORADIANS(167)),sinf(TORADIANS(168)),sinf(TORADIANS(169)),
		sinf(TORADIANS(170)),sinf(TORADIANS(171)),sinf(TORADIANS(172)),sinf(TORADIANS(173)),sinf(TORADIANS(174)),
		sinf(TORADIANS(175)),sinf(TORADIANS(176)),sinf(TORADIANS(177)),sinf(TORADIANS(178)),sinf(TORADIANS(179)),
		sinf(TORADIANS(180))
	};

	bool NuclearFPoint::isInTriangle(NuclearFPoint p0, NuclearFPoint p1, NuclearFPoint p2) const
	{
		NuclearVector2 V0 = p2-p0;
		NuclearVector2 V1 = p1-p0;
		NuclearVector2 V2 = *this-p0;

		float dot00 = DotProduct(V0, V0);
		float dot01 = DotProduct(V0, V1);
		float dot02 = DotProduct(V0, V2);
		float dot11 = DotProduct(V1, V1);
		float dot12 = DotProduct(V1, V2);
		float fcoef = 1.0f/(dot00 * dot11 - dot01 * dot01);

		float u = (dot11 * dot02 - dot01 * dot12) *fcoef;
		float v = (dot00 * dot12 - dot01 * dot02) *fcoef;

		return (u>0)&&(v>0)&&(u+v<1);
	}

	void NuclearCircle::Render(Renderer *pRenderer, const NuclearRect &viewport, NuclearColor color, NuclearFillMode fillmode, int pointR) const
	{
		pRenderer->DrawCircle(static_cast<float>(m_pos.x-viewport.left), static_cast<float>(m_pos.y-viewport.top),
			static_cast<float>(m_nRadius), color, fillmode);
		if (pointR)
		{
			Nuclear::NuclearFRectt rect;
			rect.left = static_cast<float>(m_pos.x + m_nRadius - pointR - viewport.left);
			rect.top = static_cast<float>(m_pos.y - pointR - viewport.top);
			rect.right = rect.left + pointR * 2;
			rect.bottom = rect.top + pointR * 2;
			pRenderer->DrawBox(rect, 0xFFFFFFFF, Nuclear::XPFM_WIREFRAME);
		}
	}

	float NuclearPolygon::DistanceTo(int x, int y) const
	{
		const std::vector<NuclearPoint>::size_type n = m_points.size();
		NuclearPoint q(x, y);
		switch (n)
		{
		case 0:
			return 0.0f;
			break;
		case 1:
			return sqrtf(static_cast<float>(m_points[0].Dis2(q)));
			break;
		default:
			break;
		}

		float result = 3.4e38f;
		NuclearPoint a = m_points[n - 1];
		float t, tmpr;
		for(std::vector<NuclearPoint>::size_type i = 0; i < n; ++i)
		{
			const NuclearPoint &b = m_points[i];
			NuclearPoint d(b.x - a.x, b.y - a.y);
			t = (d.x * (x - a.x) + d.y * (y - a.y)) / static_cast<float>(d.x * d.x + d.y * d.y);
			if (t <= 0)	//垂足不在线段上，距离a点更近
			{
				tmpr = sqrtf(static_cast<float>(a.Dis2(q)));
			} else if (t >= 1) {//垂足不在线段上，距离b点更近
				tmpr = sqrtf(static_cast<float>(b.Dis2(q)));
			} else {	//垂足在线段上
				NuclearFPoint q1(d.x * t + a.x, d.y * t + a.y);	//垂足
				tmpr = sqrtf(q1.Dis2(q));
			}
			if (result > tmpr)
				result = tmpr;
			a = b;
		}
		return result;
	}

	void NuclearPolygon::Render(Renderer *pRenderer, const NuclearRect &viewport, NuclearColor color, NuclearFillMode fillmode, int pointR) const
	{
		std::vector<NuclearPoint> pts(m_points.size());
		std::vector<NuclearPoint>::iterator fit = pts.begin();
		std::vector<NuclearPoint>::const_iterator cit = m_points.begin(), cie = m_points.end();
		for (;cit!=cie;++cit,++fit)
		{
			fit->x = cit->x - viewport.left;
			fit->y = cit->y - viewport.top;
		}

		pRenderer->DrawPolygon(pts, color, fillmode);

	//	pRenderer->DrawPolygon(m_points, color, fillmode);

		if (pointR)
		{
			int i = 0;
			cit = m_points.begin();
			cie = m_points.end();
			fit = pts.begin();
			int twoPointR = pointR * 2;
			NuclearFRectt* fRects = new NuclearFRectt[m_points.size()];
			for (;cit!=cie;++cit,++i,++fit)
			{
				fRects[i].left = (float)(fit->x - pointR);
				fRects[i].top = (float)(fit->y - pointR);
				fRects[i].right = fRects[i].left + twoPointR;
				fRects[i].bottom = fRects[i].top + twoPointR;
				if (i == 0)
				{
					pRenderer->DrawBox(fRects, 1, 0xFFFF0000, Nuclear::XPFM_WIREFRAME);
				}
			}
			pRenderer->DrawBox(fRects+1, i-1, 0xFFFFFFFF, Nuclear::XPFM_WIREFRAME);
			delete [] fRects;
		}
	}

	INuclearShape* NuclearPolygon::Extension(int l) const
	{
		const std::vector<NuclearPoint>::size_type n = m_points.size();
		if (n <=2 )
			return NULL;
		NuclearPoint a = m_points[n - 1];
		std::vector<NuclearVector2> nvets(n);	//各线段的单位化向量单
		float mod;
		for(std::vector<NuclearPoint>::size_type i = 0; i < n; ++i)
		{
			const NuclearPoint &b = m_points[i];
			nvets[i] = b - a;
			mod = sqrtf(nvets[i].x * nvets[i].x + nvets[i].y * nvets[i].y);
			nvets[i].x /= mod;
			nvets[i].y /= mod;
			a = b;
		}
		NuclearPolygon* pPolygon = new NuclearPolygon();
		pPolygon->m_points.resize(n);
		float sinAlpha;
		NuclearVector2 nva = nvets[n - 1];
		for(std::vector<NuclearVector2>::size_type i = 0; i < n; ++i)
		{
			const NuclearVector2 &nvb = nvets[i];
			sinAlpha = nva.x * nvb.y - nva.y * nvb.x;
			if (i == 0)
			{
				pPolygon->m_points[n-1] = m_points[n-1] + (nvb - nva) * (l / sinAlpha);
				NuclearPoint tmpPt = m_points[n-1] + (nvb - nva) / sinAlpha;
				if (IsPointIn(tmpPt.x, tmpPt.y))
				{
					l *= -1;
					pPolygon->m_points[n-1] = m_points[n-1] + (nvb - nva) * (l / sinAlpha);
				}
			} else {
				pPolygon->m_points[i-1] = m_points[i-1] + (nvb - nva) * (l / sinAlpha);
			}
			nva = nvb;
		}
		return pPolygon;
	}

	bool NuclearRectClipPolygon::ClipPolygon(NuclearRect clipWindow, const std::vector<NuclearFPoint>& polygon, std::vector<NuclearFPoint>& polygonResult)
	{
		std::vector<NuclearFPoint> polygonTemp = polygon;

		LineClipPolygon(clipWindow, LEFTLINE, polygonTemp, polygonResult);
		LineClipPolygon(clipWindow, TOPLINE, polygonTemp, polygonResult);
		LineClipPolygon(clipWindow, RIGHTLINE, polygonTemp, polygonResult);
		LineClipPolygon(clipWindow, BOTTOMLINE, polygonTemp, polygonResult);

		return true;
	}

	bool NuclearRectClipPolygon::LineClipPolygon(NuclearRect clipWindow, RectBorderType lineType, std::vector<NuclearFPoint>& polygon, std::vector<NuclearFPoint>& polygonResult)
	{
		polygonResult.clear();

		int cnt = (int)(polygon.size())-1;
		NuclearFPoint pt,pt1,pt2;
		for(int i=0; i<=cnt; i++)
		{
			pt1 = polygon[i];
			if(i != cnt)
				pt2 = polygon[i+1];
			else
				pt2 = polygon[0];

			switch(lineType)
			{
			case LEFTLINE:
				{
					if(pt1.x >= clipWindow.left)
						polygonResult.push_back(pt1);
					if((pt1.x < clipWindow.left && pt2.x > clipWindow.left) || (pt2.x < clipWindow.left && pt1.x > clipWindow.left))
					{
						if(pt1.y == pt2.y)
						{
							pt.x = (float)(clipWindow.left);
							pt.y = pt1.y;
						}
						else
							pt = ComputeCrossPoint(clipWindow, lineType, pt1, pt2);
						polygonResult.push_back(pt);
					}
				}
				break;

			case TOPLINE:
				{
					if(pt1.y >= clipWindow.top)
						polygonResult.push_back(pt1);
					if((pt1.y < clipWindow.top && pt2.y > clipWindow.top) || (pt2.y < clipWindow.top && pt1.y > clipWindow.top))
					{
						if(pt1.x == pt2.x)
						{
							pt.x = pt1.x;
							pt.y = (float)(clipWindow.top);
						}
						else
							pt = ComputeCrossPoint(clipWindow, lineType, pt1, pt2);
						polygonResult.push_back(pt);
					}
				}
				break;

			case RIGHTLINE:
				{
					if(pt1.x <= clipWindow.right)
						polygonResult.push_back(pt1);
					if((pt1.x < clipWindow.right && pt2.x > clipWindow.right) || (pt2.x < clipWindow.right && pt1.x > clipWindow.right))
					{
						if(pt1.y == pt2.y)
						{
							pt.x = (float)(clipWindow.right);
							pt.y = pt1.y;
						}
						else
							pt = ComputeCrossPoint(clipWindow, lineType, pt1, pt2);
						polygonResult.push_back(pt);
					}
				}
				break;

			case BOTTOMLINE:
				{
					if(pt1.y <= clipWindow.bottom)
						polygonResult.push_back(pt1);
					if((pt1.y < clipWindow.bottom && pt2.y > clipWindow.bottom) || (pt2.y < clipWindow.bottom && pt1.y > clipWindow.bottom))
					{
						if(pt1.x == pt2.x)
						{
							pt.x = pt1.x;
							pt.y = (float)(clipWindow.bottom);
						}
						else
							pt = ComputeCrossPoint(clipWindow, lineType, pt1, pt2);
						polygonResult.push_back(pt);
					}
				}
				break;
			default:
				break;
			}
		}

		polygon.clear();
		polygon = polygonResult;

		return true;
	}

	NuclearFPoint NuclearRectClipPolygon::ComputeCrossPoint(NuclearRect clipWindow, RectBorderType lineType, NuclearFPoint polygonPt0, NuclearFPoint polygonPt1)
	{
		//线段与直线的交点..
		NuclearFPoint pt;

		float k = (polygonPt1.y-polygonPt0.y)/(polygonPt1.x-polygonPt0.x);
		float b = (polygonPt1.x*polygonPt0.y-polygonPt0.x*polygonPt1.y)/(polygonPt1.x-polygonPt0.x);

		switch(lineType)
		{
		case LEFTLINE:
			{
				pt.x = (float)(clipWindow.left);
				pt.y = k*pt.x+b;
			}
			break;
		case TOPLINE:
			{
				pt.y = (float)(clipWindow.top);
				pt.x = (pt.y-b)/k;
			}
			break;
		case RIGHTLINE:
			{
				pt.x = (float)(clipWindow.right);
				pt.y = k*pt.x+b;
			}
			break;
		case BOTTOMLINE:
			{
				pt.y = (float)(clipWindow.bottom);
				pt.x = (pt.y-b)/k;
			}
			break;
		default:
			break;
		}

		return pt;
	}

	bool NuclearPolygonToTriangles::DecomPolygon(const std::vector<NuclearFPoint>& vextexs, std::vector<NuclearTriangle>& triangles)
	{
		int cnt = (int)(vextexs.size());
		if(cnt>V_MAX || cnt<3)
			return false;

		triangles.clear();

		int prev, cur, next;
		int vp[V_MAX];
		int count;
		int min_vert;
		int i;
		float dist;
		double min_dist;
		ORIENTATIONTYPE poly_orientation;

		poly_orientation = orientation(vextexs);

		for(i=0; i<cnt; i++)
			vp[i] = i;

		count = cnt;
		while(count > 3)
		{
			min_dist = BIG;
			min_vert = 0;
			for(cur=0; cur<count; cur++)
			{
				prev = cur-1;
				next = cur+1;
				if(cur == 0)
					prev = count-1;
				else if(cur == count-1)
					next = 0;

				if( (determinant(vp[prev], vp[cur], vp[next], vextexs) == poly_orientation)
					&& interior( vp[prev], vp[cur], vp[next], vextexs, vp, count, poly_orientation )
					&& ((dist = distance2( vextexs[vp[prev]].x, vextexs[vp[prev]].y,
					vextexs[vp[next]].x, vextexs[vp[next]].y )) < min_dist) )
				{
					min_dist = dist;
					min_vert = cur;
				}
			}

			if(min_dist == BIG)
			{
				return false;
			}

			prev = min_vert-1;
			next = min_vert+1;
			if(min_vert == 0)
				prev = count-1;
			else if(min_vert == count-1)
				next = 0;

			NuclearTriangle triangle;
			triangle.pt0.x = vextexs[vp[prev]].x;
			triangle.pt0.y = vextexs[vp[prev]].y;
			triangle.pt1.x = vextexs[vp[min_vert]].x;
			triangle.pt1.y = vextexs[vp[min_vert]].y;
			triangle.pt2.x = vextexs[vp[next]].x;
			triangle.pt2.y = vextexs[vp[next]].y;
			triangles.push_back(triangle);

			count -= 1;
			for(i=min_vert; i<count; i++)
				vp[i] = vp[i+1];
		}

		NuclearTriangle triangle;
		triangle.pt0.x = vextexs[vp[0]].x;
		triangle.pt0.y = vextexs[vp[0]].y;
		triangle.pt1.x = vextexs[vp[1]].x;
		triangle.pt1.y = vextexs[vp[1]].y;
		triangle.pt2.x = vextexs[vp[2]].x;
		triangle.pt2.y = vextexs[vp[2]].y;
		triangles.push_back(triangle);

		return true;
	}

	bool NuclearPolygonToTriangles::DecomPolygon(const std::vector<NuclearFPoint>& vextexs, const NuclearColor& cr, std::vector<NuclearTCVertex>& triangles)
	{
		triangles.clear();

		int prev, cur, next;
		int vp[V_MAX];
		int count;
		int min_vert;
		int i;
		float dist;
		double min_dist;
		ORIENTATIONTYPE poly_orientation;

		int cnt = (int)(vextexs.size());

		if(cnt>V_MAX || cnt<3)
		{
			return false;
		}

		poly_orientation = orientation(vextexs);

		for(i=0; i<cnt; i++)
			vp[i] = i;

		count = cnt;
		while(count > 3)
		{
			min_dist = BIG;
			min_vert = 0;
			for(cur=0; cur<count; cur++)
			{
				prev = cur-1;
				next = cur+1;
				if(cur == 0)
					prev = count-1;
				else if(cur == count-1)
					next = 0;

				if( (determinant(vp[prev], vp[cur], vp[next], vextexs) == poly_orientation)
					&& interior( vp[prev], vp[cur], vp[next], vextexs, vp, count, poly_orientation )
					&& ((dist = distance2( vextexs[vp[prev]].x, vextexs[vp[prev]].y,
					vextexs[vp[next]].x, vextexs[vp[next]].y )) < min_dist) )
				{
					min_dist = dist;
					min_vert = cur;
				}
			}

			if(min_dist == BIG)
			{
				return false;
			}

			prev = min_vert-1;
			next = min_vert+1;
			if(min_vert == 0)
				prev = count-1;
			else if(min_vert == count-1)
				next = 0;

			NuclearTCVertex vex;
			vex.x = vextexs[vp[prev]].x;
			vex.y = vextexs[vp[prev]].y;
			vex.c = cr.data;
			triangles.push_back(vex);

			vex.x = vextexs[vp[min_vert]].x;
			vex.y = vextexs[vp[min_vert]].y;
			vex.c = cr.data;
			triangles.push_back(vex);

			vex.x = vextexs[vp[next]].x;
			vex.y = vextexs[vp[next]].y;
			vex.c = cr.data;
			triangles.push_back(vex);

			count -= 1;
			for(i=min_vert; i<count; i++)
				vp[i] = vp[i+1];
		}

		NuclearTCVertex vex;
		vex.x = vextexs[vp[0]].x;
		vex.y = vextexs[vp[0]].y;
		vex.c = cr.data;
		triangles.push_back(vex);

		vex.x = vextexs[vp[1]].x;
		vex.y = vextexs[vp[1]].y;
		vex.c = cr.data;
		triangles.push_back(vex);

		vex.x = vextexs[vp[2]].x;
		vex.y = vextexs[vp[2]].y;
		vex.c = cr.data;
		triangles.push_back(vex);

		return true;
	}

	NuclearPolygonToTriangles::ORIENTATIONTYPE NuclearPolygonToTriangles::orientation(const std::vector<NuclearFPoint>& vextexs)
	{
		float area;
		int i;
		int cnt = vextexs.size();
		area = vextexs[cnt-1].x * vextexs[0].y - vextexs[0].x * vextexs[cnt-1].y;
		for(i=0; i<cnt-1; i++)
			area += vextexs[i].x * vextexs[i+1].y - vextexs[i+1].x * vextexs[i].y;

		if (area >= 0.0)
			return COUNTER_CLOCKWISE;
		else
			return CLOCKWISE;
	}

	NuclearPolygonToTriangles::ORIENTATIONTYPE NuclearPolygonToTriangles::determinant(int p1, int p2, int p3, const std::vector<NuclearFPoint>& vextexs)
	{
		float x1, x2, x3, y1, y2, y3;
		float determ;

		x1 = vextexs[p1].x;
		y1 = vextexs[p1].y;
		x2 = vextexs[p2].x;
		y2 = vextexs[p2].y;
		x3 = vextexs[p3].x;
		y3 = vextexs[p3].y;

		determ = (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1);
		if (determ >= 0.0f)
			return COUNTER_CLOCKWISE;
		else
			return CLOCKWISE;
	}

	float NuclearPolygonToTriangles::distance2(float x1, float y1, float x2, float y2 )
	{
		float xd, yd;
		float dist2;

		xd = x1-x2;
		yd = y1-y2;
		dist2 = xd*xd + yd*yd;

		return dist2;
	}

	int NuclearPolygonToTriangles::interior(int p1, int p2, int p3, const std::vector<NuclearFPoint>& vextexs, int vp[], int cnt, int poly_or)
	{
		int i;
		int p;

		for(i=0; i<cnt; i++)
		{
			p = vp[i];
			if((p == p1) || (p == p2) || (p == p3))
				continue;
			if ( (determinant( p2, p1, p, vextexs ) == poly_or)
				|| (determinant( p1, p3, p, vextexs ) == poly_or)
				|| (determinant( p3, p2, p, vextexs ) == poly_or) )
			{
				continue;
			}
			else
			{
				return 0;
			}
		}
		return 1;
	}

	RECT GetMaxRect(const RECT &r, float s /* height/width */)
	{
		RECT rt = r;
		LONG height = r.bottom - r.top;
		LONG width = r.right - r.left;

		float ls = height/(float)width;

		if( ls > s )
		{
			float aheight = width*s;
			rt.top = (LONG)((float)height/2 + r.top - aheight/2);
			rt.bottom = (LONG)((float)height/2 + r.top + aheight/2);
		}
		else
		{
			float awidth = height/s;
			rt.left = (LONG)((float)width/2 + r.left - awidth/2);
			rt.right = (LONG)((float)width/2 + r.left + awidth/2);
		}
		return rt;
	}

	bool IsPower2(int i)
	{
		return i>0 && !(i&(i-1));
	}

	//就在本文件使用
	static void pstp2(int length, std::vector<int>& pts)
	{
		if( length <= 0 )
			return;

		if( length > 512 )
		{
			pts.push_back(512);
			pstp2(length - 512, pts);
			return;
		}

		int np2 = 1;
		while( np2 < length) np2 *=2;

		if( np2 == length || np2 - length <= 64 )
		{
			pts.push_back(length);
		}
		else
		{
			pts.push_back(np2/2);
			pstp2(length - np2/2, pts);
		}
	}

	bool PartitionRectToPower2(const NuclearRect &src, std::vector<NuclearRect> &dst)
	{
		dst.clear();
		std::vector<int> pts_w;
		std::vector<int> pts_h;
		pstp2( src.Width(), pts_w);
		pstp2( src.Height(), pts_h);
		int top = 0;
		for(int r=0; r < (int)pts_h.size(); ++r)
		{
			int left = 0;
			int bottom = top + pts_h[r];
			for(int c=0; c < (int)pts_w.size(); ++c)
			{
				int right = pts_w[c] + left;
				//
				dst.push_back(NuclearRect(left, top, right, bottom));
				//
				left = right;
			}
			top = bottom;
		}
		if( dst.empty() )
			return false;
		return true;
	}

	void TransToDiamondRadix(int x, int y, NuclearPoint& pointInDiamonRadix)
	{
		y = static_cast<int>(static_cast<float>(y) / COS_58);
		pointInDiamonRadix.x = static_cast<int>((y + x) / 2);
		pointInDiamonRadix.y = static_cast<int>((y - x) / 2);
	}
};
