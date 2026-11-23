import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Producto {
  id: number;
  sku: string;
  nombre: string;
  descripcion: string | null;
  precio: number;
  precio_anterior: number | null;
  stock: number;
  a_pedido_dias: number | null;
  mas_vendido: boolean;
  categoria: string;
  categoria_slug: string;
  marca: string;
}

export interface Categoria {
  id: number;
  nombre: string;
  slug: string;
  productos: number;
}

export interface Health {
  api: string;
  db: string;
  postgres?: string;
}

// Capa de presentación -> capa de negocio. Las rutas /api/* las
// redirige Nginx al contenedor "backend" (ver nginx.conf).
@Injectable({ providedIn: 'root' })
export class ProductoService {
  private http = inject(HttpClient);

  productos(q = '', categoria = ''): Observable<Producto[]> {
    let params = new HttpParams();
    if (q) params = params.set('q', q);
    if (categoria) params = params.set('categoria', categoria);
    return this.http.get<Producto[]>('/api/productos', { params });
  }

  categorias(): Observable<Categoria[]> {
    return this.http.get<Categoria[]>('/api/categorias');
  }

  health(): Observable<Health> {
    return this.http.get<Health>('/api/health');
  }
}
