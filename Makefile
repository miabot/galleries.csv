all: csv index git

galleries = 100 103 110 111 112 113 114 180 200 201 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 230 235 236 237 238 239 240 241 242 243 250 251 252 253 254 255 256 257 258 259 260 261 261a 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 320 321 322 323 325 326 327 328 330 332 333 334 335 336 337 340 341 342 343 344 350 351 352 353 354 355 356 357 359 360 361 362 363 364 365 366 367 369 370 371 373 374 375 376 377 378 379 380

csv:
	for gallery in $(galleries); do echo $$gallery; curl --silent http://api.artsmia.org/gallery/G$$gallery | jq '.objects' | json2csv -f id,title,artist,date,room | uniq | sort -g > galleries/$$gallery.csv; done

index:
	cat galleries/*.csv | sort -g | uniq > index.csv

changes:
	@git diff-index --exit-code --quiet HEAD; \
		if [ $$? -eq 0 ]; then echo "no changes"; exit 1; fi

git: changes
	git add *.csv
	git commit -m "$$(date +%Y-%m-%d): $$(git status -s -- {1,2,3}*.csv | wc -l | tr -d ' ') changed"
	git push

install:
	@git --version 2&> /dev/null; if [ $$? -eq 127 ]; then echo "Install git"; fi
	@curl --version 2&> /dev/null; if [ $$? -eq 127 ]; then echo "Install curl"; fi
	@jq --version 2&> /dev/null; if [ $$? -eq 127 ]; then brew install jq; fi
	@json2csv --version 2&> /dev/null; if [ $$? -eq 127 ]; then npm install -g json2csv; fi
