/**
 *  Copyright (c) 2023 by Contributors
 *  Copyright (c) 2023, GT-TDAlab (Muhammed Fatih Balin & Umit V. Catalyurek)
 * @file cuda/isin.cu
 * @brief IsIn operator implementation on CUDA.
 */
#include <graphbolt/cuda_ops.h>
#include <thrust/binary_search.h>

#include <cub/cub.cuh>

#include "./common.h"

namespace graphbolt {
namespace ops {

torch::Tensor IsIn(torch::Tensor elements, torch::Tensor test_elements) {
  auto sorted_test_elements = Sort<false>(test_elements);
  auto allocator = cuda::GetAllocator();
  auto stream = cuda::GetCurrentStream();
  const auto exec_policy = thrust::cuda::par_nosync(allocator).on(stream);
  auto result = torch::empty_like(elements, torch::kBool);

  AT_DISPATCH_INTEGRAL_TYPES(
      elements.scalar_type(), "IsInOperation", ([&] {
        thrust::binary_search(
            exec_policy, sorted_test_elements.data_ptr<scalar_t>(),
            sorted_test_elements.data_ptr<scalar_t>() +
                sorted_test_elements.size(0),
            elements.data_ptr<scalar_t>(),
            elements.data_ptr<scalar_t>() + elements.size(0),
            result.data_ptr<bool>());
      }));
  return result;
}

}  // namespace ops
}  // namespace graphbolt
